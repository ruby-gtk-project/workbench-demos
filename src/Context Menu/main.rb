require 'gtk4'
require 'adwaita'

class ContextMenuDemo
  MOODS = { 'Happy' => '😀', 'Start Struck' => '🤩', 'Partying' => '🥳' }.freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = demo

          demo.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(box_menu_parent)
              b.append(gjs_link)
              b.append(hig_link)

              box_menu_parent.tap do |box|
                box.append(label_emoji)
                box.append(label_prompt)
                box.append(popover_menu)
                box.add_controller(gesture_click)
                box.insert_action_group('mood', mood_group)
              end
            end
          end
        end

        gesture_click.tap do |gesture|
          gesture.signal_connect('pressed') do |_, _n_press, x, y|
            popover_menu.pointing_to = Gdk::Rectangle.new(x, y, 1, 1)
            popover_menu.popup
          end
        end

        mood_group.tap do |group|
          group.add_action(emoji_action)

          emoji_action.tap do |action|
            action.signal_connect('activate') do |_, parameter|
              label_emoji.label = parameter.get_string.first
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.contextmenu', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def mood_group = @mood_group ||= Gio::SimpleActionGroup.new
  def gesture_click = @gesture_click ||= Gtk::GestureClick.new.tap { |gesture| gesture.button = 3 }
  def emoji_action = @emoji_action ||= Gio::SimpleAction.new('emoji', GLib::VariantType.new('s'))

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Context Menu'
      win.set_default_size(640, 560)
    end
  end

  def demo
    @demo ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Context Menu'
      page.description = 'Offer contextual actions'
    end
  end

  def box_menu_parent
    @box_menu_parent ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.set_size_request(300, 200)
      box.add_css_class('card')
    end
  end

  def label_emoji
    @label_emoji ||= Gtk::Label.new('😀').tap do |label|
      label.vexpand = true
      label.margin_top = 24
      label.add_css_class('title-1')
    end
  end

  def label_prompt
    @label_prompt ||= Gtk::Label.new('Right Click Me').tap do |label|
      label.margin_bottom = 24
      label.add_css_class('title-2')
    end
  end

  def popover_menu
    @popover_menu ||= Gtk::PopoverMenu.new(context_menu).tap do |popover|
      popover.has_arrow = false
      popover.halign = :start
    end
  end

  def context_menu
    @context_menu ||= Gio::Menu.new.tap do |menu|
      MOODS.each { |label, emoji| menu.append(label, "mood.emoji::#{emoji}") }
    end
  end

  def gjs_link
    @gjs_link ||= Gtk::LinkButton.new('https://gjs.guide/guides/gio/actions-and-menus.html#gmenu').tap do |btn|
      btn.label = 'GJS Guide'
      btn.margin_top = 12
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/menus.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end
end

ContextMenuDemo.new.build.run
