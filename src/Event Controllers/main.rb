require 'gtk4'
require 'adwaita'

class EventControllersDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page
          win.add_controller(key_controller)
          win.add_controller(gesture_click)

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(key_section)
              b.append(click_section)
              b.append(swipe_section)
              b.append(links_box)

              key_section.tap do |section|
                section.append(key_heading)
                section.append(ctrl_button)

                ctrl_button.tap do |btn|
                  btn.signal_connect('clicked') { toggle_ctrl_button }
                end
              end

              click_section.tap do |section|
                section.append(click_heading)
                section.append(click_buttons_box)

                click_buttons_box.tap do |box|
                  box.append(primary_button)
                  box.append(middle_button)
                  box.append(secondary_button)
                end
              end

              swipe_section.tap do |section|
                section.append(swipe_heading)
                section.append(stack_switcher)
                section.append(stack_box)
                section.append(swipe_hint)

                stack_box.tap do |box|
                  box.append(stack)

                  stack.tap do |s|
                    s.add_titled(stack_picture_1, 'stack_picture_1', 'Start')
                    s.add_titled(stack_picture_2, 'stack_picture_2', 'Finish')
                    s.add_controller(gesture_swipe)
                  end
                end
              end

              links_box.tap do |box|
                box.append(key_reference)
                box.append(click_reference)
                box.append(swipe_reference)
              end
            end
          end
        end

        key_controller.tap do |controller|
          controller.signal_connect('key-pressed') { |_, keyval, _code, _state| track_ctrl(keyval, true) }
          controller.signal_connect('key-released') { |_, keyval, _code, _state| track_ctrl(keyval, false) }
        end

        gesture_click.tap do |gesture|
          gesture.signal_connect('pressed') { flag_button('suggested-action', :add) }
          gesture.signal_connect('released') { flag_button('suggested-action', :remove) }
        end

        gesture_swipe.tap do |gesture|
          gesture.signal_connect('swipe') do |_, velocity_x, _velocity_y|
            stack.visible_child_name = velocity_x.positive? ? 'stack_picture_1' : 'stack_picture_2'
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.eventcontrollers', :default_flags)
  def key_controller = @key_controller ||= Gtk::EventControllerKey.new
  def gesture_swipe = @gesture_swipe ||= Gtk::GestureSwipe.new
  def key_section = @key_section ||= Gtk::Box.new(:vertical, 12)
  def click_section = @click_section ||= Gtk::Box.new(:vertical, 12)
  def ctrl_pressed = @ctrl_pressed ||= false
  def swipe_hint = @swipe_hint ||= Gtk::Label.new('Swipe the picture left or right')
  def stack = @stack ||= Gtk::Stack.new.tap { |s| s.transition_type = :slide_left_right }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Event Controllers'
      win.set_default_size(720, 960)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Event Controllers'
      page.description = 'Ancillary Objects which responds to events'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 36).tap { |box| box.halign = :center }
  end

  def key_heading = @key_heading ||= heading('EventControllerKey Example')
  def click_heading = @click_heading ||= heading('GestureClick Example')
  def swipe_heading = @swipe_heading ||= heading('GestureSwipe Example')

  def ctrl_button
    @ctrl_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Ctrl + Click to Activate'
      btn.width_request = 200
      btn.halign = :center
    end
  end

  def click_buttons_box
    @click_buttons_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.homogeneous = true
      box.add_css_class('linked')
    end
  end

  def primary_button = @primary_button ||= Gtk::Button.new.tap { |btn| btn.label = 'Left' }
  def middle_button = @middle_button ||= Gtk::Button.new.tap { |btn| btn.label = 'Middle' }
  def secondary_button = @secondary_button ||= Gtk::Button.new.tap { |btn| btn.label = 'Right' }

  def gesture_click
    @gesture_click ||= Gtk::GestureClick.new.tap do |gesture|
      gesture.button = 0
      gesture.propagation_phase = :capture
    end
  end

  def swipe_section
    @swipe_section ||= Gtk::Box.new(:vertical, 12).tap do |box|
      box.halign = :center
      box.valign = :start
    end
  end

  def stack_switcher = @stack_switcher ||= Gtk::StackSwitcher.new.tap { |switcher| switcher.stack = stack }

  def stack_box
    @stack_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.set_size_request(256, 256)
      box.halign = :center
    end
  end

  def stack_picture_1 = @stack_picture_1 ||= picture('image1.png')
  def stack_picture_2 = @stack_picture_2 ||= picture('image2.png')

  def links_box
    @links_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.valign = :center
    end
  end

  def key_reference = @key_reference ||= link('Event Controller Key API Reference', 'EventControllerKey')
  def click_reference = @click_reference ||= link('Gesture Click API Reference', 'GestureClick')
  def swipe_reference = @swipe_reference ||= link('Gesture Swipe API Reference', 'GestureSwipe')

  private

  def heading(text)
    Gtk::Label.new(text).tap { |label| label.add_css_class('heading') }
  end

  def link(label, class_name)
    Gtk::LinkButton.new("https://docs.gtk.org/gtk4/class.#{class_name}.html").tap { |btn| btn.label = label }
  end

  def picture(basename)
    Gtk::Picture.new(Gio::File.new_for_path(File.join(__dir__, basename))).tap do |pic|
      pic.can_shrink = true
      pic.content_fit = :scale_down
    end
  end

  def track_ctrl(keyval, pressed)
    @ctrl_pressed = pressed if [Gdk::Keyval::KEY_Control_L, Gdk::Keyval::KEY_Control_R].include?(keyval)
  end

  def toggle_ctrl_button
    if ctrl_pressed
      ctrl_button.label = 'Click to Deactivate'
      ctrl_button.add_css_class('suggested-action')
    else
      ctrl_button.label = 'Ctrl + Click to Activate'
      ctrl_button.remove_css_class('suggested-action')
    end
  end

  def flag_button(style, action)
    button_for(gesture_click.current_button).then do |btn|
      btn&.public_send("#{action}_css_class", style)
    end
  end

  def button_for(button_number)
    case button_number
    when Gdk::BUTTON_PRIMARY then primary_button
    when Gdk::BUTTON_MIDDLE then middle_button
    when Gdk::BUTTON_SECONDARY then secondary_button
    end
  end
end

EventControllersDemo.new.build.run
