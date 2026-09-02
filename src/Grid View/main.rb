require 'gtk4'
require 'adwaita'

class GridViewDemo
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
                b.append(links_box)
                b.append(buttons_box)
                b.append(stack)

                links_box.tap do |links|
                  links.append(reference_link)
                  links.append(documentation_link)
                end

                buttons_box.tap do |box|
                  box.append(add_button)
                  box.append(remove_button)

                  add_button.tap { |btn| btn.signal_connect('clicked') { add_item } }
                  remove_button.tap { |btn| btn.signal_connect('clicked') { remove_item } }
                end

                stack.tap do |s|
                  s.add_titled(scrolled_window, 'gridview', 'Grid View')

                  scrolled_window.tap do |sw|
                    sw.child = grid_view

                    grid_view.tap do |view|
                      view.model = model
                      view.factory = factory_for_grid_view
                    end
                  end
                end
              end
            end
          end
        end

        string_model.tap do |list|
          list.signal_connect('items-changed') do |_, position, removed, added|
            puts "position: #{position}, Item removed? #{removed.positive?}, Item added? #{added.positive?}"
          end
        end

        model.tap do |selection|
          selection.signal_connect('selection-changed') do
            puts "Model item selected from view: #{string_model.get_string(selection.selected)}"
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.gridview', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 240 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 18)
  def links_box = @links_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }
  def string_model = @string_model ||= Gtk::StringList.new(['Default Item 1', 'Default Item 2', 'Default Item 3'])
  def model = @model ||= Gtk::SingleSelection.new(string_model)
  def item_count = @item_count ||= 1

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Grid View'
      win.set_default_size(560, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Grid View'
      page.description = 'Arrange a large and dynamic list of items in a grid'
      page.valign = :start
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def add_button
    @add_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Add Item'
      btn.tooltip_text = 'Add Item'
    end
  end

  def remove_button
    @remove_button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Remove Item'
      btn.tooltip_text = 'Remove Item'
    end
  end

  def stack
    @stack ||= Gtk::Stack.new.tap do |s|
      s.transition_type = :crossfade
      s.vexpand = true
    end
  end

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.hscrollbar_policy = :never
      sw.propagate_natural_height = true
      sw.has_frame = true
      sw.valign = :start
    end
  end

  def grid_view
    @grid_view ||= Gtk::GridView.new.tap do |view|
      view.orientation = :vertical
      view.max_columns = 2
      view.min_columns = 2
    end
  end

  def factory_for_grid_view
    @factory_for_grid_view ||= Gtk::SignalListItemFactory.new.tap do |factory|
      factory.signal_connect('setup') do |_, list_item|
        list_item.child = Gtk::Box.new(:horizontal, 0).tap do |box|
          box.set_size_request(160, 160)
          box.add_css_class('card')
          box.append(Gtk::Label.new.tap do |label|
            label.halign = :center
            label.hexpand = true
            label.valign = :center
          end)
        end
      end

      factory.signal_connect('bind') do |_, list_item|
        list_item.child.last_child.label = list_item.item.string
      end
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.GridView.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/section-list-widget.html').tap do |btn|
      btn.label = 'Documentation'
    end
  end

  private

  def add_item
    string_model.append("New item #{item_count}")
    @item_count = item_count + 1
  end

  def remove_item
    string_model.remove(model.selected)
  end
end

GridViewDemo.new.build.run
