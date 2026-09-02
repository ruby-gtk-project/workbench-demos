require 'gtk4'
require 'adwaita'
# requiring gtksourceview5 initialises GtkSource; there is no GtkSource.init.
require 'gtksourceview5'

# libspelling has no Ruby gem; its namespace comes straight from the typelib.
module Spelling
  GObjectIntrospection::Loader.load('Spelling', self)
end

class SpellCheckerDemo
  TEXT = "This is incorrent text. \nRight click mistakes to correct them."

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(scrolled_window)
              b.append(documentation_link)

              scrolled_window.tap do |sw|
                sw.child = text_view

                text_view.tap do |view|
                  view.extra_menu = adapter.menu_model
                  view.insert_action_group('spelling', adapter)
                end
              end
            end
          end
        end

        adapter.enabled = true

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.spellchecker', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  def buffer = @buffer ||= GtkSource::Buffer.new.tap { |b| b.text = TEXT }
  def checker = @checker ||= Spelling::Checker.default.tap { |c| c.language = 'en_US' }
  def adapter = @adapter ||= Spelling::TextBufferAdapter.new(buffer, checker)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Spell Checker'
      win.set_default_size(640, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Spell Checker'
      page.description = 'Simple spell checker using libspelling'
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.set_size_request(400, 100)
      sw.has_frame = true
    end
  end

  def text_view
    @text_view ||= Gtk::TextView.new(buffer).tap do |view|
      view.top_margin = 6
      view.bottom_margin = 6
      view.left_margin = 12
      view.right_margin = 12
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libspelling/libspelling-1/'
    ).tap { |btn| btn.label = 'Documentation' }
  end
end

SpellCheckerDemo.new.build.run
