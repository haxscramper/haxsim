#include "em_main.hpp"
#include <QApplication>
#include <QDebug>
#include <QDockWidget>
#include <QGridLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLayout>
#include <QMainWindow>
#include <QPlainTextEdit>
#include <QPushButton>
#include <QSpacerItem>
#include <QVBoxLayout>
#include <cmath>

void NimMain();

MemoryTable::MemoryTable(SimCore* _core, QWidget* parent)
    : core(_core), model(new MemoryModel(_core)) {
    setModel(model.get());
    setItemDelegate(new MemoryCellDelegate());
    resizeColumnsToContents();
    horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    verticalHeader()->setSectionResizeMode(QHeaderView::ResizeToContents);
    setMinimumWidth(400);
    setMinimumHeight(400);
}

void greenBorder(QWidget* widget) {
    widget->setStyleSheet("border:1px solid rgb(0, 255, 0); ");
}

bool MemoryModel::setData(
    const QModelIndex& index,
    const QVariant&    value,
    int                role) {
    core->memSet(toAddr(index), value.toUInt());
    return true;
}

Qt::ItemFlags MemoryModel::flags(const QModelIndex& index) const {
    return QAbstractItemModel::flags(index) | Qt::ItemIsEditable;
}

int MemoryModel::getMemWidth() const { return memWidth; }

void MemoryModel::setMemWidth(int newMemWidth) { memWidth = newMemWidth; }

inline MemoryModel::MemoryModel(SimCore* _core) : core(_core) {}

int MemoryModel::rowCount(const QModelIndex& parent
                          [[maybe_unused]]) const {
    return core->memSize() / memWidth;
}

int MemoryModel::columnCount(const QModelIndex& parent
                             [[maybe_unused]]) const {
    return memWidth;
}

QVariant MemoryModel::data(
    CL<QModelIndex> index,
    int             role [[maybe_unused]]) const {
    return QVariant(core->memGet(toAddr(index)));
}

inline EPointer MemoryModel::toAddr(const QModelIndex& index) const {
    return memWidth * index.row() + index.column();
}

QVariant MemoryModel::headerData(
    int             section,
    Qt::Orientation orientation,
    int             role) const {
    if (role == Qt::DisplayRole) {
        if (orientation == Qt::Vertical) {
            return QVariant(QString("0x%1").arg(
                section,
                int(1 + std::log10(core->memSize() / memWidth)),
                16,
                QLatin1Char('0')));
        } else {
            return QVariant(QString("+0x%1").arg(section));
        }
    } else {
        return QAbstractItemModel::headerData(section, orientation, role);
    }
}

QWidget* stack(
    QBoxLayout::Direction dir,
    QWidget*              parent,
    QVector<QWidget*>     other) {
    auto result = new QWidget(parent);
    result->setLayout(new QBoxLayout(dir));
    result->setContentsMargins(0, 0, 0, 0);
    for (const auto& it : other) {
        result->layout()->addWidget(it);
    }
    return result;
}

CoreEditor::CoreEditor(SimCore* _core, QWidget* parent)
    : QWidget(parent)
    , core(_core)
    , table(new MemoryTable(_core, this))
    , tools(Tools{
          .bar     = new QToolBar(this),
          .compile = new QPushButton("Compile", this)})
    , code(new QPlainTextEdit(this)) {
    auto lmain = new QHBoxLayout();

    setLayout(lmain);
    lmain->setContentsMargins(0, 0, 0, 0);

    lmain->addWidget(stack(
        QBoxLayout::TopToBottom,
        this,
        {tools.bar, stack(QBoxLayout::LeftToRight, this, {table, code})}));

    {
        tools.bar->addWidget(tools.compile);
        tools.compile->setToolTip("Compile assembly source");
    }
}

DockWidget::DockWidget(const QString& name, QWidget* parent)
    : QDockWidget(name, parent) {}

void addGridWidgets(
    QGridLayout*                      l,
    QVector<std::pair<QWidget*, int>> widgets,
    int                               row,
    QString                           label = "",
    int                               col   = 0) {
    for (const auto& [widget, span] : widgets) {
        l->addWidget(widget, row, col, 1, span);
        col += span;
    }
    if (!label.isEmpty()) { l->addWidget(new QLabel(label), row, col); }
}

RegisterView::RegisterView(QWidget* parent)
    : DockWidget("Registers", parent)
    , segment(Segment{
          .cs = new BitEditor(2, this, "CS"),
          .ds = new BitEditor(2, this, "DS"),
          .es = new BitEditor(2, this, "ES"),
          .fs = new BitEditor(2, this, "FS"),
          .gs = new BitEditor(2, this, "GS"),
          .ss = new BitEditor(2, this, "SS"),
      })
    , main(Main{
          .eax = new BitEditor(4, this, "eax"),
          .ecx = new BitEditor(4, this, "ecs"),
          .edx = new BitEditor(4, this, "edx"),
          .ebx = new BitEditor(4, this, "ebx"),
          .ax  = new BitEditor(2, this, "ax"),
          .cx  = new BitEditor(2, this, "cx"),
          .dx  = new BitEditor(2, this, "dx"),
          .bx  = new BitEditor(2, this, "bx"),
          .ah  = new BitEditor(1, this, "ah"),
          .al  = new BitEditor(1, this, "al"),
          .ch  = new BitEditor(1, this, "ch"),
          .cl  = new BitEditor(1, this, "cl"),
          .dh  = new BitEditor(1, this, "dh"),
          .dl  = new BitEditor(1, this, "dl"),
          .bh  = new BitEditor(1, this, "bh"),
          .bl  = new BitEditor(1, this, "bl"),
      })
    , index(Index{
          .esp = new BitEditor(2, this, "esp"),
          .ebp = new BitEditor(2, this, "ebp"),
          .esi = new BitEditor(2, this, "esi"),
          .edi = new BitEditor(2, this, "edi"),
          .sp  = new BitEditor(1, this, "sp"),
          .bp  = new BitEditor(1, this, "bp"),
          .si  = new BitEditor(1, this, "si"),
          .di  = new BitEditor(1, this, "di"),
      }) {

    int row = 0;

    auto l = new QGridLayout();
    l->setVerticalSpacing(0);
    l->setHorizontalSpacing(0);
    l->setContentsMargins(0, 0, 0, 0);

    {
        l->addWidget(new QLabel("Main registers"), row, 0, 1, -1);

        auto lab = new QLabel("Accumulator");
        greenBorder(lab);
        l->addWidget(lab, row, 3, 2, 1, Qt::AlignCenter);
        addGridWidgets(l, {{main.eax, 1}, {main.ax, 2}}, ++row);
        addGridWidgets(l, {{main.ah, 1}, {main.al, 1}}, ++row, "", 1);

        l->addWidget(new QLabel("Count"), row, 3, 2, 1, Qt::AlignCenter);
        addGridWidgets(l, {{main.ecx, 1}, {main.cx, 2}}, ++row);
        addGridWidgets(l, {{main.ch, 1}, {main.cl, 1}}, ++row, "", 1);

        l->addWidget(new QLabel("Data"), row, 3, 2, 1, Qt::AlignCenter);
        addGridWidgets(l, {{main.edx, 1}, {main.dx, 2}}, ++row);
        addGridWidgets(l, {{main.dh, 1}, {main.dl, 1}}, ++row, "", 1);

        l->addWidget(new QLabel("Base"), row, 3, 2, 1, Qt::AlignCenter);
        addGridWidgets(l, {{main.ebx, 1}, {main.bx, 2}}, ++row);
        addGridWidgets(l, {{main.bh, 1}, {main.bl, 1}}, ++row, "", 1);
    }

    {
        l->addWidget(new QLabel("Index registers"), ++row, 0, 1, -1);
        addGridWidgets(l, {{index.esp, 1}, {index.sp, 2}}, ++row, "Stack");
        addGridWidgets(l, {{index.ebp, 1}, {index.bp, 2}}, ++row, "Base");
        addGridWidgets(
            l, {{index.esi, 1}, {index.si, 2}}, ++row, "Source");
        addGridWidgets(
            l, {{index.edi, 1}, {index.di, 2}}, ++row, "Destination");
    }

    {
        l->addWidget(new QLabel("Segment selectors "), ++row, 0, 1, -1);
        addGridWidgets(l, {{segment.cs, 2}}, ++row, "Code", 1);
        addGridWidgets(l, {{segment.ds, 2}}, ++row, "Data", 1);
        addGridWidgets(l, {{segment.es, 2}}, ++row, "Extra", 1);
        addGridWidgets(l, {{segment.fs, 2}}, ++row, "F", 1);
        addGridWidgets(l, {{segment.gs, 2}}, ++row, "G", 1);
        addGridWidgets(l, {{segment.ss, 2}}, ++row, "Stack", 1);
    }

    QSpacerItem* item = new QSpacerItem(
        12, 12, QSizePolicy::Expanding, QSizePolicy::Expanding);
    l->addItem(item, ++row, 0, -1, -1);

    auto w = new QWidget(this);
    w->setLayout(l);
    setWidget(w);
    setMinimumWidth(400);
}


VgaView::VgaView(QWidget* parent) : DockWidget("Vga", parent) {}


MainWindow::MainWindow()
    : core(256)
    , mem(new CoreEditor(&core, this))
    , regs(new RegisterView(this))
    , vga(new VgaView(this))
    , tools(Tools{
          .bar      = new QToolBar(),
          .next     = new QPushButton("Next", this),
          .snapshot = new QPushButton("Snapshot", this)}) {

    tools.next->setToolTip("Execute single instruction");
    tools.snapshot->setToolTip("Store current state of the emulator");

    setCentralWidget(mem);
    regs->show();
    addToolBar(tools.bar);
    tools.bar->addWidget(tools.next);
    tools.bar->addWidget(tools.snapshot);
    addDockWidget(Qt::RightDockWidgetArea, regs);
    addDockWidget(Qt::RightDockWidgetArea, vga);
    tabifyDockWidget(vga, regs);
}

int main(int argc, char** argv) {
    NimMain();
    QApplication a(argc, argv);
    MainWindow   w;
    w.resize(1200, 1200);
    w.show();
    return a.exec();
}

unsigned int BitEditor::getValue() const { return edit->text().toInt(); }

void BitEditor::setValue(unsigned int newValue) {
    edit->setText(QString::number(newValue, 16));
}

void MemoryCellDelegate::commitAndCloseEditor() {
    qDebug() << "Commit and close editor";
    BitEditor* editor = qobject_cast<BitEditor*>(sender());
    emit       commitData(editor);
    emit       closeEditor(editor);
}
