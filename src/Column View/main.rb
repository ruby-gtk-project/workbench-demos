require 'gtk4'
require 'adwaita'

# A GObject-backed model item so that sorters can use property expressions.
class Book < GLib::Object
  type_register

  install_property(GLib::Param::String.new('title', 'title', 'Title', '', GLib::Param::READWRITE))
  install_property(GLib::Param::String.new('author', 'author', 'Author', '', GLib::Param::READWRITE))
  install_property(GLib::Param::Int64.new('year', 'year', 'Year', 0, 3000, 0, GLib::Param::READWRITE))

  attr_accessor :title, :author, :year
end

class ColumnViewDemo
  BOOKS = [
    ['Winds from Afar', 'Kenji Miyazawa', 1972],
    ['Like Water for Chocolate', 'Laura Esquivel', 1989],
    ['Works and Nights', 'Alejandra Pizarnik', 1965],
    ['Understading Analysis', 'Stephen Abbott', 2002],
    ['The Timeless Way of Building', 'Cristopher Alexander', 1979],
    ['Bitter', 'Akwaeke Emezi', 2022],
    ['Saying Yes', 'Griselda Gambaro', 1981],
    ['Itinerary of a Dramatist', 'Rodolfo Usigli', 1940]
  ].freeze

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
                b.append(links_box)
                b.append(scrolled_window)

                links_box.tap do |links|
                  links.append(reference_link)
                  links.append(documentation_link)
                end

                scrolled_window.tap do |sw|
                  sw.child = column_view

                  column_view.tap do |view|
                    view.append_column(col1)
                    view.append_column(col2)
                    view.append_column(col3)
                    view.model = Gtk::SingleSelection.new(Gtk::SortListModel.new(data_model, view.sorter))
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.columnview', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 600 }
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Column View'
      win.set_default_size(720, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Column View'
      page.description = 'Arrange a large and dynamic list of items in columns'
      page.valign = :start
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.has_frame = true
      sw.propagate_natural_width = true
      sw.propagate_natural_height = true
    end
  end

  def column_view
    @column_view ||= Gtk::ColumnView.new.tap do |view|
      view.show_column_separators = true
      view.show_row_separators = true
    end
  end

  def col1 = @col1 ||= column('Title', :title, string_sorter('title'))
  def col2 = @col2 ||= column('Author', :author, string_sorter('author'))
  def col3 = @col3 ||= column('Year', :year, numeric_sorter('year'))

  def data_model
    @data_model ||= Gio::ListStore.new(Book).tap do |store|
      BOOKS.each do |title, author, year|
        store.append(Book.new.tap do |book|
          book.title = title
          book.author = author
          book.year = year
        end)
      end
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ColumnView.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/section-list-widget.html').tap do |btn|
      btn.label = 'Documentation'
    end
  end

  private

  # Passing the expression to the constructor trips an ownership assertion in
  # the bindings; assigning the property afterwards works.
  def string_sorter(property)
    Gtk::StringSorter.new(nil).tap { |sorter| sorter.expression = Gtk::PropertyExpression.new(Book, nil, property) }
  end

  def numeric_sorter(property)
    Gtk::NumericSorter.new(nil).tap { |sorter| sorter.expression = Gtk::PropertyExpression.new(Book, nil, property) }
  end

  def column(title, attribute, sorter)
    Gtk::ColumnViewColumn.new(title, cell_factory(attribute)).tap { |col| col.sorter = sorter }
  end

  def cell_factory(attribute)
    Gtk::SignalListItemFactory.new.tap do |factory|
      factory.signal_connect('setup') do |_, list_item|
        list_item.child = Gtk::Label.new.tap do |label|
          label.margin_start = 12
          label.margin_end = 12
        end
      end

      factory.signal_connect('bind') do |_, list_item|
        list_item.child.label = list_item.item.public_send(attribute).to_s
      end
    end
  end
end

ColumnViewDemo.new.build.run
