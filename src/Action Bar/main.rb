require 'gtk4'
require 'adwaita'

class ActionBarDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = card_box

          card_box.tap do |card|
            card.append(status_page)
            card.append(action_bar)

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(button)
                b.append(reference_button)

                button.tap do |btn|
                  btn.signal_connect('notify::active') { action_bar.revealed = !btn.active? }
                end
              end
            end

            action_bar.tap do |bar|
              bar.pack_start(start_widget)
              bar.pack_end(end_widget)
              bar.center_widget = center_dropdown

              start_widget.tap do |btn|
                btn.signal_connect('clicked') { puts 'Start widget' }
              end

              end_widget.tap do |btn|
                btn.signal_connect('clicked') { puts 'End widget' }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.actionbar', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 18).tap { |b| b.vexpand = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Action Bar'
      win.set_default_size(480, 820)
    end
  end

  def card_box
    @card_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.set_size_request(360, 720)
      box.halign = :center
      box.margin_top = 48
      box.margin_bottom = 48
      box.add_css_class('card')
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Action Bar'
      page.description = 'Toolbar for contextual actions'
    end
  end

  def button
    @button ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'Reveal'
      btn.halign = :center
      btn.active = false
      btn.add_css_class('pill')
      btn.add_css_class('suggested-action')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ActionBar.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def action_bar
    @action_bar ||= Gtk::ActionBar.new.tap do |bar|
      bar.revealed = true
      bar.valign = :end
    end
  end

  def start_widget = @start_widget ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'call-start-symbolic' }
  def end_widget = @end_widget ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'input-keyboard-symbolic' }

  def center_dropdown
    @center_dropdown ||= Gtk::DropDown.new.tap do |dd|
      dd.model = Gtk::StringList.new(['Center Widget', '👁️', '❤️', '💼', '🪑'])
    end
  end
end

ActionBarDemo.new.build.run
