require 'gtk4'
require 'adwaita'

class DragAndDropDemo
  ROW_TITLES = ['Row 1', 'Row 2', 'Row 3', 'Row 4', 'Row 5'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(clamp)
              b.append(reference_button)

              clamp.tap do |c|
                c.child = list

                list.tap do |l|
                  rows.each { |row| l.append(row) }
                  l.add_controller(drop_target)
                end
              end
            end
          end
        end

        rows.each { |row| make_draggable(row) }

        drop_target.tap do |target|
          target.signal_connect('drop') { |_, value, _x, y| perform_drop(value, y) }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.draganddrop', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 400 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def list = @list ||= Gtk::ListBox.new.tap { |l| l.add_css_class('boxed-list') }
  def drop_target = @drop_target ||= Gtk::DropTarget.new(Gtk::ListBoxRow.gtype, Gdk::DragAction::MOVE)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Drag and Drop'
      win.set_default_size(640, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Drag and Drop'
      page.description = 'A User interaction pattern where users drag a UI element from one place to another'
    end
  end

  def rows
    @rows ||= ROW_TITLES.map do |title|
      Adwaita::ActionRow.new.tap do |row|
        row.title = title
        row.add_prefix(drag_handle)
      end
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/drag-and-drop.html').tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 24
    end
  end

  private

  def drag_handle
    Gtk::Image.new.tap do |image|
      image.icon_name = 'list-drag-handle-symbolic'
      image.add_css_class('dim-label')
    end
  end

  def make_draggable(row)
    Gtk::DragSource.new.tap do |source|
      source.actions = Gdk::DragAction::MOVE
      row.add_controller(source)

      source.signal_connect('prepare') do |_, x, y|
        @hotspot = [x, y]
        Gdk::ContentProvider.new(GLib::Value.new(Gtk::ListBoxRow.gtype, row))
      end

      source.signal_connect('drag-begin') { |_, drag| set_drag_icon(row, drag) }
    end

    Gtk::DropControllerMotion.new.tap do |motion|
      row.add_controller(motion)
      motion.signal_connect('enter') { list.drag_highlight_row(row) }
      motion.signal_connect('leave') { list.drag_unhighlight_row }
    end
  end

  def set_drag_icon(row, drag)
    Gtk::DragIcon.get_for_drag(drag).child = drag_widget(row)
    drag.set_hotspot(*@hotspot)
  end

  def drag_widget(row)
    Gtk::ListBox.new.tap do |widget|
      widget.set_size_request(row.width, row.height)
      widget.add_css_class('boxed-list')

      Adwaita::ActionRow.new.tap do |drag_row|
        drag_row.title = row.title
        drag_row.add_prefix(drag_handle)
        widget.append(drag_row)
        widget.drag_highlight_row(drag_row)
      end
    end
  end

  def perform_drop(value, y)
    list.get_row_at_y(y).then do |target_row|
      if value.nil? || target_row.nil?
        false
      else
        list.remove(value)
        list.insert(value, target_row.index)
        target_row.set_state_flags(Gtk::StateFlags::NORMAL, true)
        true
      end
    end
  end
end

DragAndDropDemo.new.build.run
