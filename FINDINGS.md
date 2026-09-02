# Ruby GNOME binding findings

Bugs, gaps and surprises hit while porting the Workbench demos to Ruby
(`gtk4`, `adwaita`, `gtksourceview5`, `gstreamer` 4.3.x on GTK 4.22 /
libadwaita 1.9 / GObject Introspection 1.86).

Each entry records what breaks, why, and the workaround the ported demo uses.
Demos are under `src/<Demo>/main.rb`.

---

## 1. `Gtk::Accessible#update_property` / `update_relation` / `update_state` are unusable

**Symptom**

```ruby
box.update_property([Gtk::AccessibleProperty::LABEL], ['Documentation'])
# NotImplementedError: TODO: in Ruby -> GIArgument(array/C)[interface(enum)](GtkAccessibleProperty)
```

Calling them with a single argument instead raises
`wrong number of arguments (1 for 2)`, so there is no working call shape.

**Cause** — these functions take a C array of enum values. The introspection
loader has no marshaller for `array of enum`, so every call fails regardless of
argument shape.

**Workaround** — only `accessible_role=` is settable from Ruby. The
Accessibility demo sets roles and drops the programmatic
labelled-by / described-by / pressed updates, with a comment saying why.

**Affects** — `src/Accessibility/main.rb`.

---

## 2. `Gio::DBusConnection.session` does not exist

**Symptom**

```ruby
Gio::DBusConnection.session
# NoMethodError: undefined method 'session' for class Gio::DBusConnection
```

**Cause** — the convenience accessors GJS exposes are not bound; only the
introspected module-level functions are.

**Workaround**

```ruby
def session_bus = @session_bus ||= Gio.bus_get_sync(Gio::BusType::SESSION)
```

**Affects** — every XDG-portal demo: `Account`, `Camera`, `Color Picker`,
`Email`, `Location`.

---

## 3. `Adwaita::Breakpoint#add_setter` requires a real `GLib::Value`

**Symptom**

```ruby
breakpoint.add_setter(bin, 'child', label)
# Adwaita-CRITICAL: adw_breakpoint_add_setter: assertion 'G_IS_VALUE (value)' failed
```

The setter is silently not registered — the breakpoint applies but changes
nothing.

**Cause** — the parameter is a `GValue`; the loader does not box plain Ruby
objects or enum members into one.

**Workaround** — box it explicitly:

```ruby
breakpoint.add_setter(bin, 'child', GLib::Value.new(Gtk::Widget.gtype, label))
breakpoint.add_setter(image, 'icon-size', GLib::Value.new(Gtk::IconSize.gtype, Gtk::IconSize::NORMAL))
```

**Affects** — `src/Breakpoints/main.rb`.

---

## 4. Passing an expression to a sorter/filter constructor trips an ownership assertion

**Symptom**

```ruby
Gtk::StringSorter.new(Gtk::PropertyExpression.new(Book, nil, 'title'))
# GLib-GObject-CRITICAL: g_object_ref: assertion 'G_IS_OBJECT (object)' failed
```

The sorter is still constructed, but the expression argument is
transfer-full and the binding refs it as if it were a GObject.

**Cause** — `GtkExpression` is a `GTypeInstance`, not a `GObject`; the
constructor marshaller assumes the latter.

**Workaround** — construct with `nil` and assign the property afterwards:

```ruby
Gtk::StringSorter.new(nil).tap { |s| s.expression = Gtk::PropertyExpression.new(Book, nil, 'title') }
```

The same shape works for `Gtk::NumericSorter` and `Gtk::StringFilter`.

**Affects** — `src/Column View/main.rb`, `src/List Model/main.rb`,
`src/List View with Sections/main.rb`.

---

## 5. `Gtk::PopoverMenu.new(model: menu)` is rejected by its own signature

**Symptom**

```ruby
Gtk::PopoverMenu.new(model: context_menu)
# wrong arguments: Gtk::PopoverMenu#initialize({model: #<Gio::Menu>}):
# available signatures:
#   Gtk::PopoverMenu#initialize(model: (may be null) interface(Gio::MenuModel))
```

The error message lists the exact signature it just refused.

**Cause** — the keyword-argument matcher does not accept a `Gio::Menu` for a
`Gio::MenuModel` interface parameter; positional matching does.

**Workaround** — pass it positionally: `Gtk::PopoverMenu.new(context_menu)`.

**Affects** — `src/Context Menu/main.rb`.

---

## 6. `GLib::BindingFlags` members do not combine with `|` when written as symbols

**Symptom**

```ruby
sheet.bind_property('open', row, 'active', :bidirectional | :sync_create)
# NoMethodError: undefined method '|' for an instance of Symbol
```

**Cause** — a single flag accepts a symbol, but a combination has to be built
from the constants.

**Workaround**

```ruby
GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE
```

**Affects** — `src/Bottom Sheet/main.rb`, `src/Editable Label/main.rb`,
`src/Label/main.rb`, `src/HTTP Server/main.rb`.

---

## 7. Construct-only class properties are not exposed as setters

**Symptom**

```ruby
Adwaita::Bin.new.tap { |bin| bin.css_name = 'button' }
# NoMethodError: undefined method 'css_name=' for an instance of Adwaita::Bin
```

**Cause** — `css-name` is construct-only and class-wide; there is no
Ruby-side way to pass construct properties to these constructors.

**Workaround** — style the widget with CSS classes instead, or subclass and
register a new GType.

**Affects** — `src/Accessibility/main.rb`.

---

## 8. Custom GObject properties need both `install_property` and Ruby accessors

`install_property` alone registers the pspec but `set_property` then fails with
`undefined method 'title=' …`; the class also has to define the matching
accessors:

```ruby
class Book < GLib::Object
  type_register
  install_property(GLib::Param::String.new('title', 'title', 'Title', '', GLib::Param::READWRITE))
  attr_accessor :title
end
```

Also note `type_register` rejects class names shorter than three characters
(`type name 'B' is too short`).

**Affects** — `src/Column View/main.rb`, `src/Database/main.rb`,
`src/Drop Down/main.rb`, `src/List View with Sections/main.rb`.

---

## 9. Subclassing a GTK interface implementation (`Gtk::SectionModel`) is not supported

The upstream demo subclasses `Gtk.StringList` and overrides
`vfunc_get_section`. The Ruby bindings expose no equivalent of GJS's
`vfunc_*` overrides for this interface.

**Workaround** — get the same behaviour from a stock model: a
`Gtk::SortListModel` with a `section_sorter` groups rows and drives the
header factory. The demo therefore uses items carrying a `section` property
and a `Gtk::StringSorter` on that property.

**Affects** — `src/List View with Sections/main.rb`.

---

## 10. Namespaces without a ruby-gnome gem

`libportal` (Xdp), `libmanette`, `libsoup`, `libshumate`, `libspelling` and
WebKitGTK 6 ship no ruby-gnome gem. Two options, both used here:

- Load the typelib directly through GObject Introspection:

  ```ruby
  module Soup
    GObjectIntrospection::Loader.load('Soup', self)
  end
  ```

  This needs the namespace *and its dependencies* on `GI_TYPELIB_PATH` —
  `Manette` pulls in `GUdev`, for example. `flake.nix` puts them there.

- For libportal specifically there is nothing to load (`Xdp` wraps D-Bus
  itself), so the portal demos call `org.freedesktop.portal.*` through
  `Gio::DBusProxy` directly.

**Affects** — `Account`, `Camera`, `Color Picker`, `Email`, `Gamepad`,
`HTTP Image`, `HTTP Request`, `HTTP Server`, `Location`, `Map`,
`Spell Checker`, `WebSocket Client`, `Web View`.

---

## 11. Gems fail to build under Nix without their private pkg-config closure

The `pkg-config` gem resolves `Requires.private` transitively and hard-fails on
any missing `.pc`. Building `gstreamer` needed `libunwind` and `orc` on
`PKG_CONFIG_PATH` even though neither is used directly; the GTK gems need
`expat`, `libselinux`, `libdatrie`, `lerc`, `libdeflate` and friends for the
same reason. `flake.nix` lists them with a comment naming the chain each one
satisfies.

Adding `pkgs.bundler` to the shell also breaks `bundle install` — it collides
with the bundler already shipped inside `pkgs.ruby_3_4`
("The running version of Bundler (2.7.2) does not match the version of the
specification installed for it (2.6.9)").

---

## Non-issues worth recording

- `Gtk::MediaFile.new(file)`, `Gtk::Picture.new(file)` and
  `Gtk::ColumnViewColumn.new(title, factory)` all take positional arguments and
  work as expected.
- `Gio::SimpleAction.new(name)`, `(name, parameter_type)` and
  `(name, parameter_type, state)` all work.
- `Gtk::FileDialog#open`, `Gtk::FileLauncher#launch` and friends take a Ruby
  block as the async callback and pair with the matching `*_finish` method.
- `Soup::Server#listen_local(0, Soup::ServerListenOptions.new)` works; the
  options argument cannot be omitted.
- The Wikimedia API used by the HTTP Request demo rejects requests without a
  `User-Agent` header — not a binding issue, but it looks like one.

---

## 12. GtkWidget virtual functions cannot be overridden from Ruby

Subclassing `Gtk::Widget` works and the object constructs, but the bindings
never dispatch `snapshot` or `measure` to the Ruby subclass — the methods are
simply never called, with no error:

```ruby
class MyWidget < Gtk::Widget
  type_register
  def snapshot(sn) = puts('never printed')
  def measure(orientation, for_size) = [100, 100, -1, -1]
end
```

**Workaround** — draw into a `Gtk::DrawingArea` with `set_draw_func` instead.
The Snapshot demo keeps the original's `Gsk::Path` and renders it through
`Gsk::Path#to_cairo`, so only the compositing layer changes.

**Affects** — `src/Snapshot/main.rb`.

---

## 13. Widget subclasses inherit their parent's constructor, which then fails

`Gtk::ShortcutsWindow.new` runs `Gtk::Window#initialize` and dies with
`GtkWindow is not subtype of GtkShortcutsWindow`. `Gtk::ShortcutsSection.new`
inherits `Gtk::Box#initialize` and demands an orientation argument.

**Workaround** — instantiate the type through a `Gtk::Builder`:

```ruby
Gtk::Builder.new(string: '<interface><object class="GtkShortcutsWindow" id="w"/></interface>')['w']
```

The Shortcuts Window demo generates the whole `<interface>` document from a
Ruby hash of groups and shortcuts.

**Affects** — `src/Shortcuts Window/main.rb`.

---

## 14. `Adwaita::ApplicationWindow` does not accept a child

Confirms the skill's warning, with the precise failure:

```
Adwaita-ERROR: gtk_window_set_child() is not supported for AdwApplicationWindow
```

and `add_breakpoint` on it hits
`adw_breakpoint_bin_add_breakpoint: assertion 'ADW_IS_BREAKPOINT_BIN (self)' failed`.

**Workaround** — `Gtk::ApplicationWindow` with an `Adwaita::BreakpointBin` as
its child; the bin takes the breakpoints.

**Affects** — `src/Navigation Split View/main.rb`,
`src/Overlay Split View/main.rb`, `src/View Switcher/main.rb`.

---

## 15. `Gtk::ScaleButton.new` takes an options hash, not positional arguments

```ruby
Gtk::ScaleButton.new(0, 100, 15, icons)   # wrong number of arguments (given 4, expected 0..1)
Gtk::ScaleButton.new(min: 0, max: 100, step: 15, icons: icons)  # works
```

The gem overrides `initialize` with a hash-based signature (see
`gtk4/scale-button.rb`); most other widgets keep positional arguments, so this
one is easy to get wrong.

**Affects** — `src/Scale/main.rb`.

---

## 16. Named constructors are frequently not exposed

`shumate_map_source_registry_new_with_defaults` and
`rsvg_handle_new_from_file` have no Ruby counterpart; only the plain `new` (or
a different overload) is bound.

**Workarounds**

```ruby
Shumate::MapSourceRegistry.new.tap(&:populate_defaults)
Rsvg::Handle.new(Gio::File.new_for_path(path), 0, nil)
```

**Affects** — `src/Map/main.rb`, `src/SVG/main.rb`.

---

## 17. `Pango::AttrList.parse` does not exist

The function is bound as `Pango::AttrList.from_string` (and
`Pango.attr_list_from_string`), not under the C name's usual Ruby shape.

**Affects** — `src/Menu/main.rb`, `src/Text Colors/main.rb`.

---

## 18. `GtkSource.init` is not exposed — and is not needed

The upstream demos call `GtkSource.init()` explicitly. In Ruby,
`require 'gtksourceview5'` performs the initialisation and no `init` method
exists; calling it raises `undefined method 'init' for module GtkSource`.

**Affects** — `src/Source View/main.rb`, `src/Spell Checker/main.rb`.
