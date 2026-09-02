require 'gtk4'
require 'adwaita'

class NavigationViewDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(header)
              b.append(card)
              b.append(settings_group)

              header.tap do |center_box|
                center_box.start_widget = previous_button
                center_box.center_widget = title
                center_box.end_widget = next_button

                next_button.tap { |btn| btn.signal_connect('clicked') { push_next } }
                previous_button.tap { |btn| btn.signal_connect('clicked') { nav_view.pop } }
              end

              card.tap do |box|
                box.append(nav_view)

                nav_view.tap do |view|
                  view.add(nav_pageone)
                  view.add(nav_pagetwo)
                  view.add(nav_pagethree)
                  view.add(nav_pagefour)

                  view.signal_connect('notify::visible-page') { sync_buttons }

                  nav_pagefour.tap do |page4|
                    page4.child = last_status

                    last_status.tap do |status|
                      status.child = last_links_box

                      last_links_box.tap { |links| links.append(reference_button) }
                    end
                  end
                end
              end

              settings_group.tap do |group|
                group.add(decisive_button_transition)
                group.add(decisive_button_poponescape)

                nav_view.bind_property('animate-transitions', decisive_button_transition, 'active',
                                       GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
                nav_view.bind_property('pop-on-escape', decisive_button_poponescape, 'active',
                                       GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.navigationview', :default_flags)
  def status_page = @status_page ||= Adwaita::StatusPage.new
  def header = @header ||= Gtk::CenterBox.new
  def nav_view = @nav_view ||= Adwaita::NavigationView.new
  def settings_group = @settings_group ||= Adwaita::PreferencesGroup.new
  def last_links_box = @last_links_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.vexpand = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Navigation View'
      win.set_default_size(640, 820)
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap do |box|
      box.halign = :center
      box.valign = :start
    end
  end

  def card
    @card ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.set_size_request(360, 360)
      box.halign = :center
      box.add_css_class('card')
    end
  end

  def title = @title ||= Gtk::Label.new('Page 1').tap { |label| label.add_css_class('title-4') }

  def previous_button
    @previous_button ||= circular_button('go-previous-symbolic').tap { |btn| btn.sensitive = false }
  end

  def next_button = @next_button ||= circular_button('go-next-symbolic')

  def nav_pageone = @nav_pageone ||= Adwaita::NavigationPage.new(page_status('Hello'), 'Page 1')
  def nav_pagetwo = @nav_pagetwo ||= Adwaita::NavigationPage.new(page_status('From'), 'Page 2')
  def nav_pagethree = @nav_pagethree ||= Adwaita::NavigationPage.new(page_status('Workbench :)'), 'Page 3')
  def nav_pagefour = @nav_pagefour ||= Adwaita::NavigationPage.new(last_status, 'Page 4')

  def last_status
    @last_status ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Navigation View'
      page.description = 'A page-based navigation container'
    end
  end

  def decisive_button_transition
    @decisive_button_transition ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Animate Transitions' }
  end

  def decisive_button_poponescape
    @decisive_button_poponescape ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Pop on Escape' }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.NavigationView.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def pages = @pages ||= [nav_pageone, nav_pagetwo, nav_pagethree, nav_pagefour]

  private

  def circular_button(icon_name)
    Gtk::Button.new.tap do |btn|
      btn.icon_name = icon_name
      btn.add_css_class('circular')
      btn.add_css_class('suggested-action')
    end
  end

  def page_status(text)
    Adwaita::StatusPage.new.tap { |page| page.title = text }
  end

  def push_next
    pages.index(nav_view.visible_page).then do |index|
      nav_view.push(pages[index + 1]) if index && index < pages.length - 1
    end
  end

  def sync_buttons
    previous_button.sensitive = nav_view.visible_page != nav_pageone
    next_button.sensitive = nav_view.visible_page != nav_pagefour
    title.label = nav_view.visible_page.title
  end
end

NavigationViewDemo.new.build.run
