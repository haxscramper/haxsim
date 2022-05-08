#ifndef EM_MAIN_HPP
#define EM_MAIN_HPP

#include "simcore.hpp"
#include <QAbstractTableModel>
#include <QCheckBox>
#include <QDebug>
#include <QDockWidget>
#include <QLayout>
#include <QLineEdit>
#include <QMainWindow>
#include <QPainter>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QStyledItemDelegate>
#include <QTableView>
#include <QToolBar>
#include <QWidget>


class BitEditor : public QWidget
{
    Q_OBJECT
    QLineEdit* edit;
    QString    desc;
    QString    docs;
    int        bytes;

  public:
    explicit BitEditor(unsigned int value, QWidget* parent, QString _desc)
        : QWidget(parent), edit(new QLineEdit(this)), desc(_desc) {
        edit->setText(QString::number(value));
        connect(edit, &QLineEdit::editingFinished, [this]() {
            emit editingFinished();
        });
        setLayout(new QVBoxLayout());
        layout()->addWidget(edit);
    }

    unsigned int getValue() const;
    void         setValue(unsigned int newValue);

  signals:
    void editingFinished();
};

class MemoryCellDelegate : public QStyledItemDelegate
{
    Q_OBJECT

  public:
    inline QWidget* createEditor(
        QWidget*                    parent,
        const QStyleOptionViewItem& option,
        const QModelIndex&          index) const override {
        auto edit = new BitEditor(index.data().toUInt(), parent, "byte");
        auto pol  = edit->sizePolicy();
        pol.setVerticalStretch(1);
        pol.setVerticalPolicy(QSizePolicy::Expanding);
        edit->setSizePolicy(pol);

        connect(
            edit,
            &BitEditor::editingFinished,
            this,
            &MemoryCellDelegate::commitAndCloseEditor);

        return edit;
    }

    inline void setEditorData(QWidget* editor, const QModelIndex& index)
        const override {
        qobject_cast<BitEditor*>(editor)->setValue(index.data().toUInt());
    }

    inline void setModelData(
        QWidget*            editor,
        QAbstractItemModel* model,
        const QModelIndex&  index) const override {
        model->setData(
            index, QVariant(qobject_cast<BitEditor*>(editor)->getValue()));
    }

    inline void paint(
        QPainter*                   painter,
        const QStyleOptionViewItem& option,
        const QModelIndex&          index) const override {
        auto value = index.data().toUInt();
        painter->drawText(option.rect, QString::number(value, 16));
        return;
    }

    inline void updateEditorGeometry(
        QWidget*                    editor,
        const QStyleOptionViewItem& option,
        const QModelIndex& index [[maybe_unused]]) const override {
        editor->setGeometry(option.rect);
    }

  private slots:
    void commitAndCloseEditor();
};


class MemoryModel : public QAbstractTableModel
{
    SimCore* core;
    int      memWidth = 8;

    // QAbstractItemModel interface
  public:
    explicit MemoryModel(SimCore* _core);
    /// Get number of memory rows that would be displayed. Cannot be
    /// configured, depends on the size of the memory in the core emulator.
    int rowCount(const QModelIndex& parent) const override;
    /// Get number of columns for display. Can be explicitly configured,
    /// defaults to 8
    int      columnCount(const QModelIndex& parent) const override;
    QVariant data(const QModelIndex& index, int role) const override;

  private:
    EPointer toAddr(const QModelIndex& index) const;

    // QAbstractItemModel interface
  public:
    bool setData(const QModelIndex& index, const QVariant& value, int role)
        override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;
    int           getMemWidth() const;
    void          setMemWidth(int newMemWidth);

    // QAbstractItemModel interface
  public:
    QVariant headerData(int section, Qt::Orientation orientation, int role)
        const override;
};


class MemoryTable : public QTableView
{
    Q_OBJECT
    SimCore*                     core;
    std::unique_ptr<MemoryModel> model;

  public:
    explicit MemoryTable(SimCore* _core, QWidget* parent);
};


class EventItemDelegate : public QAbstractItemDelegate
{

    // QAbstractItemDelegate interface
  public:
    void paint(
        QPainter*                   painter,
        const QStyleOptionViewItem& option,
        const QModelIndex&          index) const override {}

    // QAbstractItemDelegate interface
  public:
    QSize sizeHint(
        const QStyleOptionViewItem& option,
        const QModelIndex&          index) const override {}
};


class EventModel : public QAbstractTableModel
{
    SimCore*  core;
    const int fieldNum = 3;

  public:
    explicit EventModel(SimCore* _core);

  public:
    inline int rowCount(const QModelIndex& parent) const override {
        return core->getEventNum();
    }
    inline int columnCount(const QModelIndex& parent) const override {
        return fieldNum;
    }
    QVariant data(const QModelIndex& index, int role) const override;

    inline void newRow(int idx) {
        qDebug() << "Inserted row for event" << idx;
        beginInsertRows(QModelIndex(), idx, idx);
        endInsertRows();
    }
};


class EventView : public QDockWidget
{
    Q_OBJECT
    SimCore*                    core;
    std::unique_ptr<EventModel> model;
    QTableView*                 view;

  public:
    explicit EventView(SimCore* _core, QWidget* parent);
};

class CoreEditor : public QWidget
{
    Q_OBJECT
    SimCore* core;

  public:
    explicit CoreEditor(SimCore* _core, QWidget* parent = nullptr);

  private:
    MemoryTable* table;
    struct Tools {
        QToolBar* bar;
        /// Compile input source code
        QPushButton* compile;
        /// Follow memory input and output operations
        QCheckBox* followIO;
    } tools;
    QPlainTextEdit* code;
};


class DockWidget : public QDockWidget
{
    Q_OBJECT
  public:
    explicit DockWidget(const QString& name, QWidget* parent);
};

class RegisterView : public DockWidget
{
    Q_OBJECT
  public:
    explicit RegisterView(QWidget* parent);

  private:
    struct Segment {
        BitEditor *cs, *ds, *es, *fs, *gs, *ss;
    } segment;

    struct Main {
        BitEditor *eax, *ecx, *edx, *ebx, //
            *ax, *cx, *dx, *bx,           //
            *ah, *al, *ch, *cl, *dh, *dl, *bh, *bl;

    } main;

    struct Index {
        BitEditor *esp, *ebp, *esi, *edi, *sp, *bp, *si, *di;
    } index;

    BitEditor* regs8[Reg8T_len];
    BitEditor* regs16[Reg16T_len];
    BitEditor* regs32[Reg32T_len];
};

class VgaView : public DockWidget
{
    Q_OBJECT
  public:
    explicit VgaView(QWidget* parent);
};

class MainWindow : public QMainWindow
{
    Q_OBJECT
  public:
    explicit MainWindow();

  private:
    SimCore       core;   ///< Emulator core object
    CoreEditor*   mem;    ///< Memory editor widget
    RegisterView* regs;   ///< Register editor
    VgaView*      vga;    ///< Vga emulator window
    EventView*    events; ///< Event log widget

    struct Tools {
        QToolBar*    bar;
        QPushButton *next, *snapshot;
    } tools;
};


#endif // EM_MAIN_HPP
