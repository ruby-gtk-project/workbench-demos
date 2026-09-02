require 'gtk4'
require 'adwaita'

LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ' \
        'labore et dolore magna aliqua. Vel elit scelerisque mauris pellentesque pulvinar. Molestie nunc ' \
        'non blandit massa enim nec dui nunc.'

class MenuDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = demo

          demo.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(sections_box)

              sections_box.tap do |sections|
                sections.append(primary_group)
                sections.append(context_group)
                sections.append(links_box)

                primary_group.tap { |group| group.add(menu_button) }

                context_group.tap do |group|
                  group.add(clamp)

                  clamp.tap do |c|
                    c.child = frame

                    frame.tap do |f|
                      f.child = label

                      label.tap do |l|
                        l.extra_menu = context_menu
                        l.insert_action_group('text', text_group)
                      end
                    end
                  end
                end

                links_box.tap do |box|
                  box.append(gjs_link)
                  box.append(hig_link)
                end
              end
            end
          end
        end

        text_group.tap do |group|
          group.add_action(italic_action)
          group.add_action(bold_action)
          group.add_action(color_action)

          italic_action.tap do |action|
            action.signal_connect('notify::state') do
              text_state[:italic] = action.state
              restyle
            end
          end

          bold_action.tap do |action|
            action.signal_connect('notify::state') do
              text_state[:bold] = action.state
              restyle
            end
          end

          color_action.tap do |action|
            action.signal_connect('notify::state') do
              text_state[:foreground] = action.state
              restyle
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.menu', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 500 }
  def frame = @frame ||= Gtk::Frame.new
  def text_group = @text_group ||= Gio::SimpleActionGroup.new
  def text_state = @text_state ||= { italic: false, bold: false, foreground: 'green' }
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Menu'
      win.set_default_size(720, 720)
    end
  end

  def demo
    @demo ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Menu'
      page.description = 'Display structured menus with items, sections and submenus'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  end

  def sections_box = @sections_box ||= Gtk::Box.new(:vertical, 42)

  def primary_group
    @primary_group ||= Adwaita::PreferencesGroup.new.tap do |group|
      group.title = 'Primary and Secondary Menus'
      group.description = 'Used with controls such as menu buttons'
    end
  end

  def context_group
    @context_group ||= Adwaita::PreferencesGroup.new.tap do |group|
      group.title = 'Context Menus'
      group.description = 'Menus that popup on right-clicking a widget'
    end
  end

  def menu_button
    @menu_button ||= Gtk::MenuButton.new.tap do |btn|
      btn.halign = :center
      btn.label = 'Menu Button'
      btn.menu_model = demo_menu
    end
  end

  def label
    @label ||= Gtk::Label.new(LOREM).tap do |l|
      l.margin_top = 6
      l.margin_bottom = 6
      l.margin_start = 6
      l.margin_end = 6
      l.wrap = true
      l.wrap_mode = :char
      l.selectable = true
    end
  end

  def demo_menu
    @demo_menu ||= Gio::Menu.new.tap do |menu|
      menu.append('New File', nil)

      menu.append_section(nil, Gio::Menu.new.tap do |section|
        ['New Terminal', 'New Build Terminal', 'New Runtime Terminal'].each { |item| section.append(item, nil) }
      end)

      menu.append_section('Settings', Gio::Menu.new.tap do |settings|
        settings.append_submenu('Appearance', Gio::Menu.new.tap do |appearance|
          ['System Default', 'Force Light Mode', 'Force Dark Mode'].each { |item| appearance.append(item, nil) }
        end)

        settings.append_submenu('Accessibility', Gio::Menu.new.tap do |accessibility|
          accessibility.append('High Contrast', nil)

          accessibility.append_section('Text Direction', Gio::Menu.new.tap do |direction|
            ['Left-to-Right', 'Right-to-Left'].each { |item| direction.append(item, nil) }
          end)
        end)
      end)
    end
  end

  def context_menu
    @context_menu ||= Gio::Menu.new.tap do |menu|
      menu.append('Italics', 'text.italic')
      menu.append('Bold', 'text.bold')

      menu.append_submenu('Font Color', Gio::Menu.new.tap do |colors|
        %w[green blue red].each { |color| colors.append(color.capitalize, "text.color::#{color}") }
      end)
    end
  end

  def italic_action = @italic_action ||= Gio::SimpleAction.new('italic', nil, GLib::Variant.new(false))
  def bold_action = @bold_action ||= Gio::SimpleAction.new('bold', nil, GLib::Variant.new(false))

  def color_action
    @color_action ||= Gio::SimpleAction.new('color', GLib::VariantType.new('s'), GLib::Variant.new('green'))
  end

  def gjs_link
    @gjs_link ||= Gtk::LinkButton.new('https://gjs.guide/guides/gio/actions-and-menus.html#gmenu').tap do |btn|
      btn.label = 'GJS Guide'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/menus.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  private

  def restyle
    label.attributes = Pango::AttrList.from_string(attribute_string)
  end

  def attribute_string
    [].tap do |attrs|
      attrs << '0 -1 weight bold' if text_state[:bold]
      attrs << '0 -1 style italic' if text_state[:italic]
      attrs << "0 -1 foreground #{text_state[:foreground]}"
    end.join(', ')
  end
end

MenuDemo.new.build.run
