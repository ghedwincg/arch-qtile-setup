static const char norm_fg[] = "#dee9f1";
static const char norm_bg[] = "#1e2b12";
static const char norm_border[] = "#9ba3a8";

static const char sel_fg[] = "#dee9f1";
static const char sel_bg[] = "#44C6CC";
static const char sel_border[] = "#dee9f1";

static const char urg_fg[] = "#dee9f1";
static const char urg_bg[] = "#5CADFA";
static const char urg_border[] = "#5CADFA";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
