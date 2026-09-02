require 'gtk4'
require 'adwaita'

# Noughts and crosses on a 3x3 Gtk::Grid: the player marks a cell, the demo
# marks a random free one back.
class GridDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(grid)

              grid.tap do |g|
                cells.each do |(row, column), button|
                  g.attach(button, column, row, 1, 1)
                  button.signal_connect('clicked') { play(button) }
                end

                cells[[0, 0]].child.icon_name = 'circle-outline-thick-symbolic'
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.grid', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }
  def grid = @grid ||= Gtk::Grid.new
  def step = @step ||= 1

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Grid'
      win.set_default_size(720, 720)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Grid'
      page.description = 'Arrange widgets in rows and columns'
    end
  end

  def cells
    @cells ||= (0..2).to_a.product((0..2).to_a).to_h do |row, column|
      [[row, column], cell_button(row, column)]
    end
  end

  private

  def cell_button(row, column)
    Gtk::Button.new.tap do |btn|
      btn.name = "button#{row}#{column}"
      btn.hexpand = false
      btn.add_css_class('cell')
      btn.child = Gtk::Image.new.tap { |image| image.pixel_size = 100 }
    end
  end

  def free_cells
    cells.values.reject { |button| button.child.icon_name }
  end

  def play(button)
    button.child.icon_name.then do |taken|
      unless taken
        button.child.icon_name = 'cross-large-symbolic'
        respond
      end
    end
  end

  def respond
    free_cells.sample.then do |button|
      if button && step < 8
        button.child.icon_name = 'circle-outline-thick-symbolic'
        @step = step + 2
      end
    end
  end
end

GridDemo.new.build.run
