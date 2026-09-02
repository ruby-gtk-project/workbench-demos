require 'gtk4'
require 'adwaita'

# Items carry the section they belong to, so a Gtk::SortListModel with a
# section sorter can group them — subclassing Gtk::SectionModel is not
# available through the Ruby bindings.
class SectionItem < GLib::Object
  type_register

  install_property(GLib::Param::String.new('text', 'text', 'Text', '', GLib::Param::READWRITE))
  install_property(GLib::Param::String.new('section', 'section', 'Section', '', GLib::Param::READWRITE))

  attr_accessor :text, :section
end

class ListViewSectionsDemo
  ITEM_COUNT = 200
  SECTION_SIZE = 5

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
                    view.factory = item_factory
                    view.header_factory = header_factory
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

  def app = @app ||= Gtk::Application.new('org.example.listviewsections', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 360 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 18)
  def list_view = @list_view ||= Gtk::ListView.new
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'List View with Sections'
      win.set_default_size(640, 680)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'List View with Sections'
      page.description = 'Divide items in a list view with sections'
      page.valign = :start
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.height_request = 330
      sw.has_frame = true
    end
  end

  def store
    @store ||= Gio::ListStore.new(SectionItem).tap do |list|
      (1..ITEM_COUNT).each do |index|
        list.append(SectionItem.new.tap do |item|
          item.text = "Item #{index}"
          item.section = "Items #{((index - 1) / SECTION_SIZE) * SECTION_SIZE + 1}–" \
                         "#{((index - 1) / SECTION_SIZE + 1) * SECTION_SIZE}"
        end)
      end
    end
  end

  def section_sorter
    @section_sorter ||= Gtk::StringSorter.new(nil).tap do |sorter|
      sorter.expression = Gtk::PropertyExpression.new(SectionItem, nil, 'section')
    end
  end

  def sorted_model
    @sorted_model ||= Gtk::SortListModel.new(store, nil).tap { |model| model.section_sorter = section_sorter }
  end

  def selection_model = @selection_model ||= Gtk::NoSelection.new(sorted_model)

  def item_factory
    @item_factory ||= Gtk::SignalListItemFactory.new.tap do |factory|
      factory.signal_connect('setup') do |_, list_item|
        list_item.child = Gtk::Label.new.tap do |label|
          label.margin_start = 12
          label.halign = :start
        end
      end

      factory.signal_connect('bind') do |_, list_item|
        list_item.child.label = list_item.item.text
      end
    end
  end

  def header_factory
    @header_factory ||= Gtk::SignalListItemFactory.new.tap do |factory|
      factory.signal_connect('setup') do |_, list_header|
        list_header.child = Gtk::Label.new.tap { |label| label.halign = :start }
      end

      factory.signal_connect('bind') do |_, list_header|
        list_header.child.label = list_header.item.section
      end
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/iface.SectionModel.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new(
      'https://docs.gtk.org/gtk4/section-list-widget.html#sections'
    ).tap { |btn| btn.label = 'Documentation' }
  end
end

ListViewSectionsDemo.new.build.run
