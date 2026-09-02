require 'gtk4'
require 'adwaita'

class ToastsDemo
  MESSAGE_ID = '42'

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = overlay
          win.add_action(action_console)

          overlay.tap do |o|
            o.child = status_page

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(button_simple)
                b.append(button_advanced)
                b.append(tutorial_link)
                b.append(reference_link)
                b.append(hig_link)

                button_simple.tap do |btn|
                  btn.signal_connect('clicked') { show_simple_toast }
                end

                button_advanced.tap do |btn|
                  btn.signal_connect('clicked') { overlay.add_toast(advanced_toast) }
                end
              end
            end
          end
        end

        action_console.tap do |action|
          action.signal_connect('activate') { |_, target| puts "undo #{target.get_string.first}" }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.toasts', :default_flags)
  def overlay = @overlay ||= Adwaita::ToastOverlay.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def action_console = @action_console ||= Gio::SimpleAction.new('undo', GLib::VariantType.new('s'))

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Toasts'
      win.set_default_size(640, 620)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Toasts'
      page.description = 'In-app notifications'
    end
  end

  def button_simple = @button_simple ||= pill_button('Simple')
  def button_advanced = @button_advanced ||= pill_button('Advanced')

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/getting_started/adding_toasts.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Toast.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/toasts.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def pill_button(label)
    Gtk::Button.new.tap do |btn|
      btn.label = label
      btn.margin_bottom = 30
      btn.add_css_class('pill')
    end
  end

  def show_simple_toast
    overlay.add_toast(simple_toast)
    button_simple.sensitive = false
  end

  def simple_toast
    Adwaita::Toast.new('Toasts are delicious!').tap do |toast|
      toast.timeout = 1
      toast.signal_connect('dismissed') { button_simple.sensitive = true }
    end
  end

  def advanced_toast
    Adwaita::Toast.new('Message sent').tap do |toast|
      toast.button_label = 'Undo'
      toast.action_name = 'win.undo'
      toast.action_target = GLib::Variant.new(MESSAGE_ID)
      toast.priority = Adwaita::ToastPriority::HIGH
    end
  end
end

ToastsDemo.new.build.run
