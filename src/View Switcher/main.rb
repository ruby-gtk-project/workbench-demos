require 'gtk4'
require 'adwaita'

class ViewSwitcherDemo
  NOTIFICATION_COUNT = 5

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = breakpoint_bin

          breakpoint_bin.tap do |bin|
            bin.child = content_box
            bin.add_breakpoint(breakpoint)
          end

          content_box.tap do |box|
            box.append(header_bar)
            box.append(stack)
            box.append(switcher_bar)

            header_bar.tap { |bar| bar.title_widget = switcher_title }

            stack.tap do |s|
              s.add_titled_with_icon(favorites_status, 'page1', 'Favorites', 'star-filled-rounded-symbolic')
              s.add_titled_with_icon(recents_status, 'page2', 'Recents', 'clock-alt-symbolic')
              s.add_titled_with_icon(notifications_status, 'page3', 'Notifications', 'bell-outline-symbolic')
              s.add_titled_with_icon(account_status, 'page4', 'Account', 'person-symbolic')

              favorites_status.tap { |page| page.child = links_box('page1') }
              recents_status.tap { |page| page.child = links_box('page2') }
              account_status.tap { |page| page.child = links_box('page4') }

              notifications_status.tap do |page|
                page.child = clamp

                clamp.tap do |c|
                  c.child = notification_list

                  notification_list.tap do |list|
                    NOTIFICATION_COUNT.times { list.append(notification_row) }
                  end
                end
              end
            end
          end
        end

        notifications_page.tap do |page|
          page.badge_number = NOTIFICATION_COUNT
          page.needs_attention = true
        end

        breakpoint.tap do |bp|
          bp.add_setter(header_bar, 'title-widget', GLib::Value.new(Gtk::Widget.gtype, nil))
          bp.add_setter(switcher_bar, 'reveal', GLib::Value.new(GLib::Type::BOOLEAN, true))
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.viewswitcher', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def stack = @stack ||= Adwaita::ViewStack.new.tap { |s| s.vexpand = true }
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 500 }
  def switcher_bar = @switcher_bar ||= Adwaita::ViewSwitcherBar.new.tap { |bar| bar.stack = stack }

  # Adwaita::ApplicationWindow cannot take a child through the Ruby bindings,
  # so breakpoints come from an Adwaita::BreakpointBin.
  def breakpoint_bin = @breakpoint_bin ||= Adwaita::BreakpointBin.new.tap { |bin| bin.set_size_request(360, 360) }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'AdwViewSwitcher Demo'
      win.set_default_size(760, 640)
    end
  end

  def breakpoint
    @breakpoint ||= Adwaita::Breakpoint.new(Adwaita::BreakpointCondition.parse('max-width: 550sp'))
  end

  def switcher_title
    @switcher_title ||= Adwaita::ViewSwitcher.new.tap do |switcher|
      switcher.stack = stack
      switcher.policy = :wide
    end
  end

  def favorites_status = @favorites_status ||= icon_status('Favorites', 'star-filled-rounded-symbolic')
  def recents_status = @recents_status ||= icon_status('Recents', 'clock-alt-symbolic')
  def account_status = @account_status ||= icon_status('Account', 'person-symbolic')

  def notifications_status
    @notifications_status ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Notifications'
      page.valign = :start
      page.margin_start = 15
      page.margin_end = 15
    end
  end

  def notifications_page = @notifications_page ||= stack.get_page(notifications_status)

  def notification_list
    @notification_list ||= Gtk::ListBox.new.tap do |list|
      list.halign = :baseline
      list.add_css_class('boxed-list')
    end
  end

  private

  def icon_status(title, icon_name)
    Adwaita::StatusPage.new.tap do |page|
      page.title = title
      page.icon_name = icon_name
    end
  end

  def links_box(_page_name)
    Gtk::Box.new(:vertical, 0).tap do |box|
      box.valign = :center
      box.append(reference_link)
      box.append(hig_link)
    end
  end

  def reference_link
    Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.ViewSwitcher.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/nav/view-switchers.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  def notification_row
    Adwaita::ActionRow.new.tap do |row|
      row.title = 'Notification'
      row.selectable = false
      row.add_suffix(dismiss_button(row))
    end
  end

  def dismiss_button(row)
    Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.valign = :center
      btn.margin_top = 10
      btn.margin_bottom = 10
      btn.icon_name = 'check-plain-symbolic'
      btn.signal_connect('clicked') { dismiss(row) }
    end
  end

  def dismiss(row)
    notifications_page.badge_number -= 1
    notification_list.remove(row)
    notifications_page.needs_attention = false if notifications_page.badge_number.zero?
  end
end

ViewSwitcherDemo.new.build.run
