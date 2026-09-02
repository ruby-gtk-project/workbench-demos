require 'gtk4'
require 'adwaita'
require 'sqlite3'

# Rows come back from SQLite as plain values; wrapping them in a GObject lets
# the ColumnView bind to them.
class Item < GLib::Object
  type_register

  install_property(GLib::Param::Int.new('id', 'id', 'Id', 0, 2**31 - 1, 0, GLib::Param::READWRITE))
  install_property(GLib::Param::String.new('text', 'text', 'Text', '', GLib::Param::READWRITE))

  attr_accessor :id, :text
end

class DatabaseDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(insert_box)
              b.append(search_box)
              b.append(scrolled_window)
              b.append(links_box)

              insert_box.tap do |box|
                box.append(text_entry)
                box.append(insert_button)

                insert_button.tap do |btn|
                  btn.signal_connect('clicked') { insert_row }
                end
              end

              search_box.tap do |box|
                box.append(search_label)
                box.append(search_entry)

                search_entry.tap do |entry|
                  entry.signal_connect('search-changed') { load_rows }
                end
              end

              scrolled_window.tap do |sw|
                sw.child = column_view

                column_view.tap do |view|
                  view.append_column(column_text)
                  view.append_column(column_id)
                  view.model = Gtk::SingleSelection.new(data_model)
                end
              end

              links_box.tap do |box|
                box.append(reference_link)
                box.append(sqlite_link)
              end
            end
          end
        end

        create_table
        load_rows

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.database', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  def data_model = @data_model ||= Gio::ListStore.new(Item)
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }
  def search_label = @search_label ||= Gtk::Label.new('Search by Text')
  def column_view = @column_view ||= Gtk::ColumnView.new.tap { |v| v.show_column_separators = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Database'
      win.set_default_size(640, 860)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Database'
      page.description = 'Search, load and store data using SQLite'
    end
  end

  def insert_box
    @insert_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.add_css_class('linked') }
  end

  def text_entry
    @text_entry ||= Gtk::Entry.new.tap do |entry|
      entry.placeholder_text = 'Enter Text'
      entry.hexpand = true
    end
  end

  def insert_button = @insert_button ||= Gtk::Button.new.tap { |btn| btn.label = 'Insert' }

  def search_box
    @search_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.hexpand = true }
  end

  def search_entry = @search_entry ||= Gtk::SearchEntry.new.tap { |entry| entry.search_delay = 100 }

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.set_size_request(340, 340)
      sw.has_frame = true
    end
  end

  def column_text = @column_text ||= column('Text', :text)
  def column_id = @column_id ||= column('Id', :id)

  def database
    @database ||= SQLite3::Database.new(File.join(__dir__, 'db.sqlite'))
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://gjs-docs.gnome.org/gom10~1.0/').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def sqlite_link
    @sqlite_link ||= Gtk::LinkButton.new('https://www.sqlite.org/').tap { |btn| btn.label = 'SQLite' }
  end

  private

  def column(title, attribute)
    Gtk::ColumnViewColumn.new(title, cell_factory(attribute)).tap { |col| col.expand = true }
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

  def create_table
    database.execute('CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)')
  end

  def insert_row
    database.execute('INSERT INTO items (text) VALUES (?)', [text_entry.text])
    text_entry.text = ''
    load_rows
  end

  def load_rows
    data_model.remove_all

    database.execute('SELECT id, text FROM items WHERE text GLOB ?', ["*#{search_entry.text}*"]).each do |id, text|
      data_model.append(Item.new.tap do |item|
        item.id = id
        item.text = text
      end)
    end
  end
end

DatabaseDemo.new.build.run
