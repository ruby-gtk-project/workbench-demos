require 'gtk4'
require 'adwaita'

class AboutDialogDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = box

            box.tap do |b|
              b.append(button)
              b.append(reference_button)

              button.tap do |btn|
                btn.signal_connect('clicked') { about_dialog.present(window) }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.aboutdialog', :default_flags)
  def box = @box ||= Gtk::Box.new(:vertical, 0).tap { |b| b.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'About Dialog'
      win.set_default_size(640, 480)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'About Dialog'
      page.description = 'A dialog showing information about the application'
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'About'
      btn.margin_bottom = 12
      btn.add_css_class('pill')
      btn.add_css_class('suggested-action')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.AboutDialog.html'
    ).tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def about_dialog
    @about_dialog ||= Adwaita::AboutDialog.new.tap do |dialog|
      dialog.application_icon = 'application-x-executable'
      dialog.application_name = 'Typeset'
      dialog.developer_name = 'Angela Avery'
      dialog.version = '1.2.3'
      dialog.comments = 'Typeset is an app that doesn’t exist and is used as an example content for About Dialog.'
      dialog.website = 'https://example.org'
      dialog.issue_url = 'https://example.org'
      dialog.support_url = 'https://example.org'
      dialog.copyright = '© 2023 Angela Avery'
      dialog.license_type = Gtk::License::GPL_3_0_ONLY
      dialog.developers = ['Angela Avery <angela@example.org>']
      dialog.artists = ['GNOME Design Team']
      dialog.translator_credits = 'translator-credits'
      dialog.add_link('Documentation',
                      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.AboutDialog.html')
      dialog.add_legal_section(
        'Fonts',
        nil,
        Gtk::License::CUSTOM,
        "This application uses font data from <a href='https://example.org'>somewhere</a>."
      )
      dialog.add_acknowledgement_section('Special thanks to', ['My cat'])
    end
  end
end

AboutDialogDemo.new.build.run
