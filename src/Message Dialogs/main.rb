require 'gtk4'
require 'adwaita'

class MessageDialogsDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button_confirmation)
              b.append(button_error)
              b.append(button_advanced)
              b.append(reference_link)
              b.append(hig_link)

              button_confirmation.tap do |btn|
                btn.signal_connect('clicked') { choose(confirmation_dialog) }
              end

              button_error.tap do |btn|
                btn.signal_connect('clicked') { choose(error_dialog) }
              end

              button_advanced.tap do |btn|
                btn.signal_connect('clicked') { choose(advanced_dialog) { |response| report_login(response) } }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.messagedialogs', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Message Dialogs'
      win.set_default_size(560, 620)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Message Dialogs'
      page.description = 'Present options, choices or information to users'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  end

  def button_confirmation = @button_confirmation ||= pill_button('Confirmation Dialog')
  def button_error = @button_error ||= pill_button('Error Dialog')
  def button_advanced = @button_advanced ||= pill_button('Advanced Error Dialog')

  def confirmation_dialog
    @confirmation_dialog ||= Adwaita::AlertDialog.new(
      'Replace File?',
      'A file named “example.png” already exists. Do you want to replace it?'
    ).tap do |dialog|
      dialog.close_response = 'cancel'
      dialog.add_response('cancel', 'Cancel')
      dialog.add_response('replace', 'Replace')
      # DESTRUCTIVE draws attention to the damaging consequences of the action.
      dialog.set_response_appearance('replace', Adwaita::ResponseAppearance::DESTRUCTIVE)
    end
  end

  def error_dialog
    @error_dialog ||= Adwaita::AlertDialog.new('Critical Error', 'Something unexpected happened').tap do |dialog|
      dialog.close_response = 'okay'
      dialog.add_response('okay', 'Okay')
    end
  end

  def advanced_dialog
    @advanced_dialog ||= Adwaita::AlertDialog.new('Login', 'A valid password is needed to continue').tap do |dialog|
      dialog.close_response = 'cancel'
      dialog.add_response('cancel', 'Cancel')
      dialog.add_response('login', 'Login')
      # SUGGESTED marks important responses such as the affirmative action.
      dialog.set_response_appearance('login', Adwaita::ResponseAppearance::SUGGESTED)
      dialog.extra_child = password_entry
    end
  end

  def password_entry = @password_entry ||= Gtk::PasswordEntry.new.tap { |entry| entry.show_peek_icon = true }

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.AlertDialog.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/feedback/dialogs.html#message-dialogs'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def pill_button(label)
    Gtk::Button.new.tap do |btn|
      btn.label = label
      btn.margin_bottom = 30
      btn.add_css_class('pill')
    end
  end

  def choose(dialog, &report)
    dialog.choose(window, nil) do |source, result|
      source.choose_finish(result).then do |response|
        report ? report.call(response) : puts("Selected \"#{response}\" response.")
      end
    end
  end

  def report_login(response)
    if response == 'login'
      puts "Selected \"#{response}\" response with password \"#{password_entry.text}\""
    else
      puts "Selected \"#{response}\" response."
    end
  end
end

MessageDialogsDemo.new.build.run
