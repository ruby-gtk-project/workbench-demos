require 'gtk4'
require 'adwaita'

# The upstream demo overrides GtkWidget's snapshot and measure vfuncs. The Ruby
# bindings never dispatch those to a subclass, so the chessboard is drawn in a
# Gtk::DrawingArea instead — the knight still comes from a Gsk::Path, rendered
# through Gsk::Path#to_cairo.
class Chessboard
  SQUARE_SIZE = 70
  BOARD_SIZE = 8 * SQUARE_SIZE
  PIECE_SIZE = 1.5 * SQUARE_SIZE

  # Made by SVG Repo: https://www.svgrepo.com/svg/380957/chess-piece-knight-strategy
  KNIGHT_PATH = 'M47.26,22.08c-.74-3.36-5.69-5.27-7.74-5.92l.34-4.5a1,1,0,0,0-1.74-.74L33.9,15.66c-6.45,2.23-11,' \
                '6-13.39,11.19-2.9,6.19-2.2,12.94-1.29,17.06H13.71l-1.27,9.5H50.08l-1.27-9.5h-8c.85-4.13-3-10.63-' \
                '5.59-14.53A5.93,5.93,0,0,0,39,28.1c2.85,1.17,9.48,2.29,10.77,2,1-.19,1.3-1.33,1.5-2.09,0-.12,0-.' \
                '22,0-.23C52.4,25.82,49.64,23.63,47.26,22.08Zm-.2,23.83.74,5.5H14.72l.74-5.5h31.6Zm2.27-18.35a4.87,' \
                '4.87,0,0,1-.19.63c-1.6,0-7.92-1.13-9.8-2.13a1,1,0,0,0-1.11.11,4.25,4.25,0,0,1-3.06,1.2A3.65,3.65,' \
                '0,0,1,33,26.23a1,1,0,0,0-1.39-.16,1,1,0,0,0-.17,1.4C34,30.74,40.19,40,38.78,43.91H21.28c-.87-3.79-' \
                '1.7-10.37,1-16.21,2.22-4.76,6.42-8.2,12.47-10.23a1,1,0,0,0,.43-.29l2.43-2.72-.18,2.36a1,1,0,0,0,' \
                '.74,1c1.78.47,6.92,2.39,7.13,4.9a1,1,0,0,0,.46.76,15.42,15.42,0,0,1,3.25,2.54,2.06,2.06,0,0,1,' \
                '.51.8A3,3,0,0,0,49.33,27.56Z'

  def build
    drawing_area.tap do |area|
      area.set_draw_func { |_, cr, _width, _height| draw(cr) }
      area.add_controller(gesture)

      gesture.tap do |g|
        g.signal_connect('drag-begin') { |_, x, y| begin_drag(x, y) }
        g.signal_connect('drag-update') { |_, dx, dy| update_drag(dx, dy) }
        g.signal_connect('drag-end') { |_, dx, dy| end_drag(dx, dy) }
      end
    end
  end

  def drawing_area
    @drawing_area ||= Gtk::DrawingArea.new.tap do |area|
      area.content_width = BOARD_SIZE
      area.content_height = BOARD_SIZE
      area.hexpand = true
      area.vexpand = true
    end
  end

  def gesture = @gesture ||= Gtk::GestureDrag.new
  def knight_path = @knight_path ||= Gsk::Path.parse(KNIGHT_PATH)
  def knight_bounds = @knight_bounds ||= knight_path.get_stroke_bounds(Gsk::Stroke.new(2.0)).last
  def initial_x = @initial_x ||= 4 * SQUARE_SIZE - PIECE_SIZE / 2
  def initial_y = @initial_y ||= 4 * SQUARE_SIZE - PIECE_SIZE / 2
  def x = @x ||= initial_x
  def y = @y ||= initial_y

  private

  def draw(cr)
    draw_board(cr)
    draw_knight(cr)
  end

  # The board is a 2x2 block of squares repeated across the whole surface.
  def draw_board(cr)
    8.times do |row|
      8.times do |column|
        cr.set_source_rgb(*((row + column).even? ? [0.83, 0.83, 0.83] : [0.5, 0.5, 0.5]))
        cr.rectangle(column * SQUARE_SIZE, row * SQUARE_SIZE, SQUARE_SIZE, SQUARE_SIZE)
        cr.fill
      end
    end
  end

  def draw_knight(cr)
    cr.save
    cr.translate(x, y)
    (PIECE_SIZE / knight_bounds.width).then { |factor| cr.scale(factor, factor) }
    knight_path.to_cairo(cr)
    cr.set_source_rgb(0, 0, 0)
    cr.set_line_width(2.0)
    cr.stroke
    cr.restore
  end

  def begin_drag(pointer_x, pointer_y)
    @dragging = Graphene::Rect.new.init(initial_x, initial_y, PIECE_SIZE, PIECE_SIZE)
                              .contains_point(Graphene::Point.new.init(pointer_x, pointer_y))
  end

  def update_drag(offset_x, offset_y)
    @dragging.then do |dragging|
      if dragging
        @x = initial_x + offset_x
        @y = initial_y + offset_y
        drawing_area.queue_draw
      end
    end
  end

  def end_drag(offset_x, offset_y)
    @dragging.then do |dragging|
      if dragging
        @initial_x = initial_x + offset_x
        @initial_y = initial_y + offset_y
        @dragging = false
        drawing_area.queue_draw
      end
    end
  end
end

class SnapshotDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = scrolled_window

          scrolled_window.tap do |sw|
            sw.child = status_page

            status_page.tap do |page|
              page.child = box

              box.tap do |b|
                b.append(label)
                b.append(chessboard.build)
                b.append(links_box)

                links_box.tap do |links|
                  links.append(snapshot_reference)
                  links.append(custom_widgets_link)
                  links.append(drawing_model_link)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.snapshot', :default_flags)
  def scrolled_window = @scrolled_window ||= Gtk::ScrolledWindow.new
  def chessboard = @chessboard ||= Chessboard.new
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)
  def label = @label ||= Gtk::Label.new('Drag the knight with your mouse')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Snapshot'
      win.set_default_size(700, 860)
    end
  end

  def status_page = @status_page ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Snapshot' }

  def box
    @box ||= Gtk::Box.new(:vertical, 12).tap { |b| b.halign = :center }
  end

  def snapshot_reference
    @snapshot_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Snapshot.html').tap do |btn|
      btn.label = 'Snapshot API Reference'
    end
  end

  def custom_widgets_link
    @custom_widgets_link ||= Gtk::LinkButton.new(
      'https://blog.gtk.org/2020/04/24/custom-widgets-in-gtk-4-drawing/'
    ).tap { |btn| btn.label = 'Custom Widgets' }
  end

  def drawing_model_link
    @drawing_model_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/drawing-model.html').tap do |btn|
      btn.label = 'Drawing Model'
    end
  end
end

SnapshotDemo.new.build.run
