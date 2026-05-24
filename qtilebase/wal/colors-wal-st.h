const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#1e2b12", /* black   */
  [1] = "#5CADFA", /* red     */
  [2] = "#44C6CC", /* green   */
  [3] = "#68E0E8", /* yellow  */
  [4] = "#A5C3A9", /* blue    */
  [5] = "#92B9FB", /* magenta */
  [6] = "#9FE2EB", /* cyan    */
  [7] = "#dee9f1", /* white   */

  /* 8 bright colors */
  [8]  = "#9ba3a8",  /* black   */
  [9]  = "#5CADFA",  /* red     */
  [10] = "#44C6CC", /* green   */
  [11] = "#68E0E8", /* yellow  */
  [12] = "#A5C3A9", /* blue    */
  [13] = "#92B9FB", /* magenta */
  [14] = "#9FE2EB", /* cyan    */
  [15] = "#dee9f1", /* white   */

  /* special colors */
  [256] = "#1e2b12", /* background */
  [257] = "#dee9f1", /* foreground */
  [258] = "#dee9f1",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
