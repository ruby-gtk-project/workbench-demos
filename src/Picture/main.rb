require 'gtk4'
require 'adwaita'

class PictureDemo
  FITS = [
    [:fill, 'Fill',
     'Make the content fill the entire allocation, without taking its aspect ratio in consideration. The ' \
     'resulting content will appear as stretched if its aspect ratio is different from the allocation ' \
     'aspect ratio.'],
    [:contain, 'Contain',
     'Scale the content to fit the allocation, while taking its aspect ratio in consideration. The ' \
     'resulting content will appear as letterboxed if its aspect ratio is different from the allocation ' \
     'aspect ratio.'],
    [:cover, 'Cover',
     'Cover the entire allocation, while taking the content aspect ratio in consideration. The resulting ' \
     'content will appear as clipped if its aspect ratio is different from the allocation aspect ratio.'],
    [:scale_down, 'Scale Down',
     'The content is scaled down to fit the allocation, if needed, otherwise its original size is used']
  ].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(stack_switcher)
              b.append(stack)
              b.append(reference_button)

              stack.tap do |s|
                FITS.each { |fit, title, description| s.add_titled(page_for(fit, description), fit.to_s, title) }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.picture', :default_flags)
  def stack = @stack ||= Gtk::Stack.new
  def file = @file ||= Gio::File.new_for_path(File.join(__dir__, 'keys.png'))

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Picture'
      win.set_default_size(720, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Picture'
      page.description = 'Display images at their natural sizes'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap do |box|
      box.margin_start = 24
      box.margin_end = 24
    end
  end

  def stack_switcher
    @stack_switcher ||= Gtk::StackSwitcher.new.tap do |switcher|
      switcher.stack = stack
      switcher.halign = :center
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Picture.html').tap do |btn|
      btn.label = 'API Reference'
      btn.margin_bottom = 12
    end
  end

  private

  def page_for(fit, description)
    Gtk::Box.new(:vertical, 12).tap do |box|
      box.append(picture(fit))
      box.append(Gtk::Label.new(description).tap do |label|
        label.wrap = true
        label.margin_bottom = 24
      end)
    end
  end

  def picture(fit)
    Gtk::Picture.new(file).tap do |pic|
      pic.halign = :center
      pic.valign = :center
      pic.can_shrink = true
      pic.content_fit = fit
    end
  end
end

PictureDemo.new.build.run
