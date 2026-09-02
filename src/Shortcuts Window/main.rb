require 'gtk4'
require 'adwaita'

class ShortcutsWindowDemo
  GROUPS = {
    'Application' => {
      '<Control>Return' => 'Run Code',
      '<Shift><Control>Return' => 'Format',
      '<Control>N' => 'New Project',
      '<Control>O' => 'Open Project',
      '<Shift><Control>O' => 'Open Library',
      '<Shift><Control>I' => 'Inspector',
      '<Control>W' => 'Close Window',
      '<Control>M' => 'Reveal in Files',
      '<Control>question' => 'Keyboard Shortcuts',
      '<Control>Q' => 'Quit'
    },
    'Editor' => {
      '<Control>X' => 'Cut',
      '<Control>C' => 'Copy',
      '<Control>V' => 'Paste',
      '<Control>F' => 'Find',
      '<Control>Z' => 'Undo',
      '<Control>space' => 'Show code suggestions',
      '<Shift><Control>Z' => 'Redo'
    },
    'Console' => {
      '<Shift><Control>K' => 'Toggle Console',
      '<Shift><Control>C' => 'Copy',
      '<Shift><Control>A' => 'Select All',
      '<Control>K' => 'Clear'
    }
  }.freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button)
              b.append(links_box)

              button.tap do |btn|
                btn.signal_connect('clicked') { shortcuts_window.present }
              end

              links_box.tap do |box|
                box.append(reference_link)
                box.append(hig_link)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.shortcutswindow', :default_flags)
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Shortcuts Window'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Shortcuts Window'
      page.description = 'A window showing the application’s keyboard shortcuts'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 50).tap { |box| box.halign = :center }
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Open'
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  # Gtk::ShortcutsWindow, Gtk::ShortcutsSection and Gtk::ShortcutsGroup all
  # inherit a constructor from their parent class through the Ruby bindings
  # ("GtkWindow is not subtype of GtkShortcutsWindow"; GtkBox's orientation
  # argument for the section), so the whole window is described in XML and
  # instantiated with a Gtk::Builder.
  def shortcuts_window
    @shortcuts_window ||= Gtk::Builder.new(string: shortcuts_xml)['shortcuts_window'].tap do |win|
      win.hide_on_close = true
    end
  end

  def shortcuts_xml
    @shortcuts_xml ||= <<~XML
      <interface>
        <object class="GtkShortcutsWindow" id="shortcuts_window">
          <child>
            <object class="GtkShortcutsSection">
              <property name="section-name">Shortcuts</property>
              <property name="max-height">18</property>
      #{GROUPS.map { |title, shortcuts| group_xml(title, shortcuts) }.join}
            </object>
          </child>
        </object>
      </interface>
    XML
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ShortcutsWindow.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/reference/keyboard.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  private

  def group_xml(title, shortcuts)
    <<~XML
      <child>
        <object class="GtkShortcutsGroup">
          <property name="title">#{title}</property>
      #{shortcuts.map { |accelerator, name| shortcut_xml(accelerator, name) }.join}
        </object>
      </child>
    XML
  end

  def shortcut_xml(accelerator, title)
    <<~XML
      <child>
        <object class="GtkShortcutsShortcut">
          <property name="accelerator">#{accelerator}</property>
          <property name="title">#{title}</property>
        </object>
      </child>
    XML
  end
end

ShortcutsWindowDemo.new.build.run
