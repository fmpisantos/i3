1. First, create the custom XKB layout (if you haven't already):
bashsudo nano /usr/share/X11/xkb/symbols
```

Add:
```
// Custom US layout with swapped numbers and symbols
partial alphanumeric_keys
xkb_symbols "swapped" {
    name[Group1]= "English (US, swapped numbers)";

    include "us(basic)"

    key <AE01> { [ exclam,      1 ] };
    key <AE02> { [ at,          2 ] };
    key <AE03> { [ numbersign,  3 ] };
    key <AE04> { [ dollar,      4 ] };
    key <AE05> { [ percent,     5 ] };
    key <AE06> { [ asciicircum, 6 ] };
    key <AE07> { [ ampersand,   7 ] };
    key <AE08> { [ asterisk,    8 ] };
    key <AE09> { [ parenleft,   9 ] };
    key <AE10> { [ parenright,  0 ] };
};
2. Register it in the XKB rules:
bashsudo nano /usr/share/X11/xkb/rules/evdev.xml
Find the <layoutList> section for the us and add (before </layoutList>):
        <variant>
          <configItem>
            <name>us_swapped</name>
            <description>English (US, swapped numbers)</description>
          </configItem>
        </variant>
3. Clear XKB cache:
bashsudo rm -rf /var/lib/xkb/*
