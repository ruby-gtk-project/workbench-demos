require 'gtk4'
require 'adwaita'

class NotificationDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button_simple)
              b.append(tutorial_link)
              b.append(reference_link)
              b.append(hig_link)

              button_simple.tap do |btn|
                btn.signal_connect('clicked') { app.send_notification('lunch-is-ready', notification) }
              end
            end
          end
        end

        actions.each do |action, message|
          app.add_action(action)
          action.signal_connect('activate') { puts message }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.notification', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Notification'
      win.set_default_size(560, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Notification'
      page.description = 'Desktop notifications'
    end
  end

  def button_simple
    @button_simple ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Trigger Notification'
      btn.margin_bottom = 30
      btn.add_css_class('pill')
    end
  end

  # https://docs.gtk.org/gio/class.Notification.html
  def notification
    @notification ||= Gio::Notification.new('Lunch is ready').tap do |n|
      n.body = 'Today we have pancakes and salad, and fruit and cake for dessert'
      n.set_default_action('app.notification-reply')
      n.add_button('Accept', 'app.notification-accept')
      n.add_button('Decline', 'app.notification-decline')
      n.icon = Gio::ThemedIcon.new('object-rotate-right-symbolic')
    end
  end

  def actions
    @actions ||= {
      Gio::SimpleAction.new('notification-reply') => 'Reply',
      Gio::SimpleAction.new('notification-accept') => 'Accept',
      Gio::SimpleAction.new('notification-decline') => 'Decline'
    }
  end

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/notifications.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gio/class.Notification.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/notifications.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end
end

NotificationDemo.new.build.run
