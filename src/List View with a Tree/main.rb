require 'gtk4'
require 'adwaita'

# Tree nodes are GObjects so that Gio::ListStore and Gtk::TreeListModel can
# hold them.
class TreeNode < GLib::Object
  type_register

  attr_accessor :title, :children

  def initialize(title, children = [])
    super()
    @title = title
    @children = children
  end
end

# One row of the tree: an expander plus its label.
class TreeRow
  def build
    box.tap do |b|
      b.append(expander)
      b.append(label)
    end
  end

  def update(list_row)
    expander.list_row = list_row
    label.label = list_row.item.title
  end

  def box
    @box ||= Gtk::Box.new(:horizontal, 6).tap do |b|
      b.margin_start = 6
      b.margin_end = 12
      b.margin_top = 6
      b.margin_bottom = 6
    end
  end

  def expander = @expander ||= Gtk::TreeExpander.new
  def label = @label ||= Gtk::Label.new.tap { |l| l.halign = :start }
end

class ListViewTreeDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(scrolled_window)
                b.append(links_box)

                scrolled_window.tap do |sw|
                  sw.child = list_view

                  list_view.tap do |view|
                    view.factory = factory
                    view.model = selection_model
                  end
                end

                links_box.tap do |box|
                  box.append(reference_link)
                  box.append(documentation_link)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.listviewtree', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 360 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 18)
  def list_view = @list_view ||= Gtk::ListView.new
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }
  def rows = @rows ||= {}

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'List View with a Tree'
      win.set_default_size(640, 660)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'List View with a Tree'
      page.description = 'Arrange items in a tree like structure'
      page.valign = :start
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.has_frame = true
      sw.height_request = 320
    end
  end

  def root_node
    @root_node ||= TreeNode.new('Root', [
                                  TreeNode.new('Child 1', [TreeNode.new('Child 1.1'), TreeNode.new('Child 1.2')]),
                                  TreeNode.new('Child 2', [TreeNode.new('Child 2.1'), TreeNode.new('Child 2.2'),
                                                           TreeNode.new('Child 2.3', [TreeNode.new('Child 3.1')])])
                                ])
  end

  def tree_model
    @tree_model ||= Gio::ListStore.new(TreeNode).tap { |store| store.append(root_node) }
  end

  def tree_list_model
    @tree_list_model ||= Gtk::TreeListModel.new(tree_model, false, true) { |item| child_model(item) }.tap do |model|
      model.autoexpand = false
    end
  end

  def selection_model = @selection_model ||= Gtk::NoSelection.new(tree_list_model)

  def factory
    @factory ||= Gtk::SignalListItemFactory.new.tap do |f|
      f.signal_connect('setup') do |_, list_item|
        TreeRow.new.tap do |row|
          list_item.child = row.build
          rows[list_item] = row
        end
      end

      f.signal_connect('bind') do |_, list_item|
        rows[list_item].update(list_item.item)
      end
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.TreeListModel.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new(
      'https://docs.gtk.org/gtk4/section-list-widget.html#displaying-trees'
    ).tap { |btn| btn.label = 'Documentation' }
  end

  private

  def child_model(item)
    item.children.empty? ? nil : Gio::ListStore.new(TreeNode).tap do |store|
      item.children.each { |child| store.append(child) }
    end
  end
end

ListViewTreeDemo.new.build.run
