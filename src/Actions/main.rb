require 'gtk4'
require 'adwaita'

class ActionsDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = demo

          demo.tap do |page|
            page.child = clamp
            page.insert_action_group('demo', demo_group)

            demo_group.tap do |group|
              group.add_action(simple_action)
              group.add_action(bookmarks_action)
              group.add_action(toggle_action)
              group.add_action(scale_action)
              group.add_action(alignment_action)
            end

            simple_action.tap do |action|
              action.signal_connect('activate') { puts "#{action.name} action activated" }
            end

            bookmarks_action.tap do |action|
              action.signal_connect('activate') do |_, parameter|
                puts "#{action.name} activated with #{parameter.get_string.first}"
              end
            end

            toggle_action.tap do |action|
              action.signal_connect('notify::state') { puts "#{action.name} action set to #{action.state}" }
            end

            scale_action.tap do |action|
              action.signal_connect('notify::state') { puts "#{action.name} action set to #{action.state}" }
            end

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(actions_box)
                b.append(links_box)

                actions_box.tap do |ab|
                  ab.append(activatable_group)
                  ab.append(stateful_group)
                  ab.append(specialized_group)

                  activatable_group.tap do |group|
                    group.add(activatable_box)

                    activatable_box.tap do |box|
                      box.append(simple_button)
                      box.append(menu_button)
                    end
                  end

                  stateful_group.tap do |group|
                    group.add(stateful_box)

                    stateful_box.tap do |box|
                      box.append(toggle_column)
                      box.append(scale_column)

                      toggle_column.tap do |column|
                        column.append(toggle_heading)
                        column.append(toggle_switch)
                      end

                      scale_column.tap do |column|
                        column.append(scale_heading)
                        column.append(scale_buttons)

                        scale_buttons.tap do |buttons|
                          scale_toggles.each { |toggle| buttons.append(toggle) }
                        end
                      end
                    end
                  end

                  specialized_group.tap do |group|
                    group.add(specialized_box)

                    specialized_box.tap do |box|
                      box.append(text)
                      box.append(align_buttons)

                      align_buttons.tap do |buttons|
                        align_checks.each { |check| buttons.append(check) }
                      end
                    end
                  end
                end

                links_box.tap do |box|
                  box.append(gjs_link)
                  box.append(gtk_link)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.actions', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def demo_group = @demo_group ||= Gio::SimpleActionGroup.new
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |b| b.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Actions'
      win.set_default_size(720, 800)
    end
  end

  def demo
    @demo ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Actions'
      page.description = 'A high-level interface used to describe a piece of functionality'
    end
  end

  def actions_box
    @actions_box ||= Gtk::Box.new(:vertical, 24).tap do |box|
      box.homogeneous = true
      box.vexpand = true
    end
  end

  def activatable_group
    @activatable_group ||= Adwaita::PreferencesGroup.new.tap do |group|
      group.title = 'Activatable Actions'
      group.description = 'Stateless actions that optionally take parameters'
    end
  end

  def stateful_group
    @stateful_group ||= Adwaita::PreferencesGroup.new.tap do |group|
      group.title = 'Stateful Actions'
      group.description = 'Actions with a closely-associated state'
    end
  end

  def specialized_group
    @specialized_group ||= Adwaita::PreferencesGroup.new.tap do |group|
      group.title = 'Specialized Actions'
      group.description = 'A stateful action which is bound to a GObject property'
    end
  end

  def activatable_box
    @activatable_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_top = 6
      box.margin_bottom = 6
      box.hexpand = true
      box.homogeneous = true
    end
  end

  def stateful_box
    @stateful_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_top = 6
      box.margin_bottom = 6
      box.hexpand = true
      box.homogeneous = true
    end
  end

  def specialized_box
    @specialized_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.margin_top = 6
      box.margin_bottom = 12
      box.homogeneous = true
    end
  end

  def simple_button
    @simple_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Simple Action'
      btn.halign = :center
      btn.action_name = 'demo.simple'
      btn.add_css_class('pill')
    end
  end

  def menu_button
    @menu_button ||= Gtk::MenuButton.new.tap do |btn|
      btn.label = 'Bookmarks'
      btn.halign = :center
      btn.menu_model = bookmarks_menu
      btn.add_css_class('pill')
    end
  end

  def toggle_column = @toggle_column ||= Gtk::Box.new(:vertical, 6).tap { |b| b.valign = :center }
  def scale_column = @scale_column ||= Gtk::Box.new(:vertical, 6)

  def toggle_heading
    @toggle_heading ||= Gtk::Label.new('Toggle Action').tap { |l| l.add_css_class('heading') }
  end

  def scale_heading
    @scale_heading ||= Gtk::Label.new('Scale').tap { |l| l.add_css_class('heading') }
  end

  def toggle_switch
    @toggle_switch ||= Gtk::Switch.new.tap do |sw|
      sw.halign = :center
      sw.valign = :center
      sw.action_name = 'demo.toggle'
    end
  end

  def scale_buttons
    @scale_buttons ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.valign = :center
      box.add_css_class('linked')
    end
  end

  def scale_toggles
    @scale_toggles ||= ['100%', '150%', '200%'].map do |value|
      Gtk::ToggleButton.new.tap do |btn|
        btn.label = value
        btn.set_detailed_action_name("demo.scale::#{value}")
      end
    end
  end

  def text
    @text ||= Gtk::Label.new('Text Align').tap do |label|
      label.halign = :center
      label.add_css_class('heading')
    end
  end

  def align_buttons = @align_buttons ||= Gtk::Box.new(:horizontal, 6).tap { |b| b.halign = :center }

  def align_checks
    @align_checks ||= { 'Start' => 'start', 'Center' => 'center', 'End' => 'end' }.map do |label, value|
      Gtk::CheckButton.new.tap do |check|
        check.label = label
        check.set_detailed_action_name("demo.text-align::#{value}")
      end
    end
  end

  def simple_action = @simple_action ||= Gio::SimpleAction.new('simple')

  def bookmarks_action
    @bookmarks_action ||= Gio::SimpleAction.new('open-bookmarks', GLib::VariantType.new('s'))
  end

  def toggle_action
    @toggle_action ||= Gio::SimpleAction.new('toggle', nil, GLib::Variant.new(false))
  end

  def scale_action
    @scale_action ||= Gio::SimpleAction.new('scale', GLib::VariantType.new('s'), GLib::Variant.new('100%'))
  end

  def alignment_action = @alignment_action ||= Gio::PropertyAction.new('text-align', text, 'halign')

  def bookmarks_menu
    @bookmarks_menu ||= Gio::Menu.new.tap do |menu|
      ['Developer Documentation', 'Human Interface Guidelines', 'GNOME Javascript'].each do |title|
        menu.append(title, "demo.open-bookmarks::#{title}")
      end

      menu.append_section('Actions Documentation', Gio::Menu.new.tap do |section|
        section.append('GJS Guide', 'app.open_uri::https://gjs.guide/guides/gio/actions-and-menus.html')
        section.append('GTK Documentation', 'app.open_uri::https://docs.gtk.org/gtk4/actions.html')
      end)
    end
  end

  def gjs_link
    @gjs_link ||= Gtk::LinkButton.new('https://gjs.guide/guides/gio/actions-and-menus.html').tap do |btn|
      btn.label = 'GJS Guide'
    end
  end

  def gtk_link
    @gtk_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/actions.html').tap do |btn|
      btn.label = 'GTK Documentation'
    end
  end
end

ActionsDemo.new.build.run
