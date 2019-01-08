/*-*- mode: css; -*-*/

configuration {
    show-icons:   false;
    sidebar-mode: false;

}

* {
    // Default bg is transparent.
    background-color: transparent;
    text-color:       {{FOREGROUND}};
    spacing:          8;
}

#window {
    // Default font
    font: "Roboto 12";
    fullscreen: true;
    transparency: "background";

    background-color: {{BACKGROUND}}99;

    // Add dummy widgets on top and bottom so the sizing
    // nicely centers hdum, independent of resolution.
                                        children: [ dummy1, hdum, dummy2 ];

}

#hdum {
    orientation: horizontal;
    // Add dummy widgets on left and right so the sizing
    // nicely centers mainbox, independent of resolution.
                                           children: [ dummy3, mainbox, dummy4 ];

}

#element selected {
    text-color: {{HIGHLIGHT}};
}
