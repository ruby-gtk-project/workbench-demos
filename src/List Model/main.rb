require 'gtk4'
require 'adwaita'

class ListModelDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(documentation_link)
                b.append(stack_switcher)
                b.append(stack)

                stack.tap do |s|
                  s.add_titled(list_box_page, 'listbox', 'List Box')
                  s.add_titled(flow_box_frame, 'flowbox', 'Flow Box')
                  s.add_titled(edit_page, 'Filter', 'Edit')
                  s.signal_connect('notify::visible-child') { puts 'View changed' }

                  list_box_page.tap { |box| box.append(list_box) }
                  flow_box_frame.tap { |frame| frame.child = flow_box }

                  edit_page.tap do |box|
                    box.append(edit_controls)
                    box.append(list_box_editable)

                    edit_controls.tap do |controls|
                      controls.append(search_entry)
                      controls.append(add_button)
                      controls.append(remove_button)

                      search_entry.tap do |entry|
                        entry.signal_connect('search-changed') { filter.search = entry.text }
                      end

                      add_button.tap { |btn| btn.signal_connect('clicked') { add_item } }
                      remove_button.tap { |btn| btn.signal_connect('clicked') { remove_item } }
                    end

                    list_box_editable.tap do |list|
                      list.signal_connect('row-selected') { remove_button.sensitive = !list.selected_row.nil? }
                    end
                  end
                end
              end
            end
          end
        end

        model.tap do |m|
          m.signal_connect('items-changed') do |_, position, removed, added|
            puts "position: #{position}, Item removed? #{removed.positive?}, Item added? #{added.positive?}"
          end
        end

        list_box.bind_model(model) { |item| action_row(item.string) }
        flow_box.bind_model(model) { |item| flow_card(item.string) }
        list_box_editable.bind_model(filter_model) { |item| action_row(item.string) }

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.listmodel', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 640 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def model = @model ||= Gtk::StringList.new(['Default Item 1', 'Default Item 2', 'Default Item 3'])
  def item_count = @item_count ||= 1
  def list_box_page = @list_box_page ||= Gtk::Box.new(:horizontal, 0)
  def edit_page = @edit_page ||= Gtk::Box.new(:vertical, 12)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'List Model'
      win.set_default_size(720, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'List Model'
      page.description = 'List models are a simple interface for ordered lists of GObject instances'
      page.valign = :start
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new('https://gjs.guide/guides/gio/list-models.html').tap do |btn|
      btn.label = 'Documentation'
    end
  end

  def stack_switcher
    @stack_switcher ||= Gtk::StackSwitcher.new.tap do |switcher|
      switcher.stack = stack
      switcher.halign = :center
    end
  end

  def stack
    @stack ||= Gtk::Stack.new.tap do |s|
      s.transition_type = :crossfade
      s.vexpand = true
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.hexpand = true
      list.valign = :start
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def flow_box_frame
    @flow_box_frame ||= Gtk::Frame.new.tap do |frame|
      frame.hexpand = true
      frame.valign = :start
    end
  end

  def flow_box
    @flow_box ||= Gtk::FlowBox.new.tap do |box|
      box.orientation = :horizontal
      box.selection_mode = :none
    end
  end

  def edit_controls
    @edit_controls ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def search_entry = @search_entry ||= Gtk::SearchEntry.new.tap { |e| e.placeholder_text = 'Search items' }

  def add_button
    @add_button ||= Gtk::Button.new.tap do |btn|
      btn.icon_name = 'list-add-symbolic'
      btn.tooltip_text = 'Add Item'
    end
  end

  def remove_button
    @remove_button ||= Gtk::Button.new.tap do |btn|
      btn.icon_name = 'list-remove-symbolic'
      btn.tooltip_text = 'Remove Item'
      btn.sensitive = false
    end
  end

  def list_box_editable
    @list_box_editable ||= Gtk::ListBox.new.tap do |list|
      list.hexpand = true
      list.valign = :start
      list.activate_on_single_click = true
      list.selection_mode = :single
      list.add_css_class('boxed-list')
    end
  end

  def filter
    @filter ||= Gtk::StringFilter.new(nil).tap do |f|
      f.expression = Gtk::PropertyExpression.new(Gtk::StringObject, nil, 'string')
      f.ignore_case = true
      f.match_mode = :substring
    end
  end

  def filter_model
    @filter_model ||= Gtk::FilterListModel.new(model, filter).tap { |m| m.incremental = true }
  end

  private

  def action_row(title)
    Adwaita::ActionRow.new.tap { |row| row.title = title }
  end

  def flow_card(title)
    Adwaita::Bin.new.tap do |bin|
      bin.set_size_request(160, 160)
      bin.add_css_class('card')
      bin.valign = :start
      bin.child = Gtk::Label.new(title).tap do |label|
        label.halign = :center
        label.hexpand = true
        label.valign = :center
      end
    end
  end

  def add_item
    model.append("New Item #{item_count}")
    @item_count = item_count + 1
  end

  def remove_item
    list_box_editable.selected_row.then { |row| model.remove(row.index) if row }
  end
end

ListModelDemo.new.build.run
