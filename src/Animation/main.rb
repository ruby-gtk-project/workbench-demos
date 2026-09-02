require 'gtk4'
require 'adwaita'

class AnimationDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = clamp

          clamp.tap do |c|
            c.child = content_box

            content_box.tap do |b|
              b.append(header_box)
              b.append(demos_box)
              b.append(links_box)

              header_box.tap do |header|
                header.append(title_label)
                header.append(subtitle_label)
              end

              demos_box.tap do |demos|
                demos.append(target_container)
                demos.append(callback_target_container)

                target_container.tap do |container|
                  container.append(timed_header)
                  container.append(progress_box)

                  timed_header.tap do |header|
                    header.append(timed_labels)
                    header.append(button_timed)

                    timed_labels.tap do |labels|
                      labels.append(timed_title)
                      labels.append(timed_subtitle)
                    end

                    button_timed.tap do |btn|
                      btn.signal_connect('clicked') { animation_timed.play }
                    end
                  end

                  progress_box.tap { |box| box.append(progress_bar) }
                end

                callback_target_container.tap do |container|
                  container.append(spring_header)
                  container.append(ball_box)

                  spring_header.tap do |header|
                    header.append(spring_labels)
                    header.append(button_spring)

                    spring_labels.tap do |labels|
                      labels.append(spring_title)
                      labels.append(spring_subtitle)
                    end

                    button_spring.tap do |btn|
                      btn.signal_connect('clicked') { animation_spring.play }
                    end
                  end

                  ball_box.tap { |box| box.append(ball) }
                end
              end

              links_box.tap do |links|
                links.append(tools_title)
                links.append(elastic_link)
                links.append(references_title)
                links.append(timed_reference)
                links.append(spring_reference)
              end
            end
          end
        end

        animation_timed.tap do |animation|
          animation.signal_connect('done') { animation.reset }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.animation', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def progress_bar = @progress_bar ||= Gtk::ProgressBar.new.tap { |bar| bar.hexpand = true }
  def progress_box = @progress_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.hexpand = true }
  def ball_box = @ball_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.hexpand = true }
  def ball = @ball ||= Adwaita::Bin.new.tap { |bin| bin.add_css_class('ball') }
  def header_box = @header_box ||= Gtk::Box.new(:vertical, 6)
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)
  def timed_header = @timed_header ||= Gtk::Box.new(:horizontal, 24)
  def spring_header = @spring_header ||= Gtk::Box.new(:horizontal, 24)
  def timed_labels = @timed_labels ||= Gtk::Box.new(:vertical, 0).tap { |box| box.homogeneous = true }
  def spring_labels = @spring_labels ||= Gtk::Box.new(:vertical, 0).tap { |box| box.homogeneous = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Animation'
      win.set_default_size(640, 720)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.margin_top = 30
      box.margin_bottom = 12
    end
  end

  def title_label = @title_label ||= Gtk::Label.new('Animation').tap { |l| l.add_css_class('title-1') }
  def subtitle_label = @subtitle_label ||= Gtk::Label.new('Create timed or spring based animations')

  def demos_box
    @demos_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.margin_top = 54
      box.homogeneous = true
    end
  end

  def target_container
    @target_container ||= Gtk::Box.new(:vertical, 12).tap { |box| box.vexpand = true }
  end

  def callback_target_container = @callback_target_container ||= Gtk::Box.new(:vertical, 12)

  def timed_title = @timed_title ||= heading('Animation Target')
  def timed_subtitle = @timed_subtitle ||= dim_label('Animate a widget property')
  def spring_title = @spring_title ||= heading('Callback Animation Target')
  def spring_subtitle = @spring_subtitle ||= dim_label('Use callbacks to animate a custom property')

  def button_timed = @button_timed ||= play_button
  def button_spring = @button_spring ||= play_button

  def tools_title = @tools_title ||= Gtk::Label.new('Tools').tap { |l| l.add_css_class('title-2') }

  def references_title
    @references_title ||= Gtk::Label.new('API References').tap do |label|
      label.margin_top = 12
      label.add_css_class('title-2')
    end
  end

  def elastic_link
    @elastic_link ||= Gtk::LinkButton.new('https://apps.gnome.org/Elastic/').tap do |btn|
      btn.label = 'Elastic'
      btn.margin_bottom = 12
    end
  end

  def timed_reference
    @timed_reference ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.TimedAnimation.html'
    ).tap { |btn| btn.label = 'Timed Animation' }
  end

  def spring_reference
    @spring_reference ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.SpringAnimation.html'
    ).tap { |btn| btn.label = 'Spring Animation' }
  end

  def target_timed = @target_timed ||= Adwaita::PropertyAnimationTarget.new(progress_bar, 'fraction')

  def animation_timed
    @animation_timed ||= Adwaita::TimedAnimation.new(progress_bar, 0, 1, 1500, target_timed).tap do |animation|
      animation.easing = Adwaita::Easing::EASE_IN_OUT_CUBIC
    end
  end

  def target_spring
    @target_spring ||= Adwaita::CallbackAnimationTarget.new { |value| move_ball(value) }
  end

  def spring_params = @spring_params ||= Adwaita::SpringParams.new(0.5, 1.0, 50.0)

  def animation_spring
    @animation_spring ||= Adwaita::SpringAnimation.new(ball, 0, 1, spring_params, target_spring).tap do |animation|
      animation.initial_velocity = 1.0
      animation.epsilon = 0.001
      animation.clamp = false
    end
  end

  private

  def heading(text)
    Gtk::Label.new(text).tap do |label|
      label.halign = :start
      label.add_css_class('title-4')
    end
  end

  def dim_label(text)
    Gtk::Label.new(text).tap do |label|
      label.halign = :start
      label.add_css_class('dim-label')
    end
  end

  def play_button
    Gtk::Button.new.tap do |btn|
      btn.icon_name = 'media-playback-start-symbolic'
      btn.hexpand = true
      btn.halign = :end
      btn.valign = :center
      btn.add_css_class('circular')
    end
  end

  # The ball has no "position" property, so the callback target moves it by
  # re-allocating it with a translation transform.
  def move_ball(value)
    ball.allocate(
      ball.width,
      ball.height,
      -1,
      Gsk::Transform.new.translate(Graphene::Point.new(Adwaita.lerp(0, ball.parent.width - ball.width, value), 0))
    )
  end
end

AnimationDemo.new.build.run
