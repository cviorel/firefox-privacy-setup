// PREF: startup / new tab page
// 0=blank, 1=home, 2=last visited page, 3=resume previous session
// [NOTE] Session Restore is cleared with history and not used in Private Browsing mode
// [SETTING] General>Startup>Open previous windows and tabs
user_pref("browser.startup.page", 3);

// PREF: disable region updates
// [1] https://firefox-source-docs.mozilla.org/toolkit/modules/toolkit_modules/Region.html
user_pref("browser.region.update.enabled", false);
user_pref("browser.region.network.url", "");

// PREF: controls if a double-click word selection also deletes one adjacent whitespace
// This mimics native behavior on macOS.
user_pref("editor.word_select.delete_space_after_doubleclick_selection", true);

// PREF: Bookmarks Toolbar visibility
// always, never, or newtab
user_pref("browser.toolbars.bookmarks.visibility", "always");

// PREF: improve font rendering by using DirectWrite everywhere like Chrome [WINDOWS]
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
user_pref("gfx.font_rendering.cleartype_params.force_gdi_classic_for_families", "");
user_pref("gfx.font_rendering.cleartype_params.force_gdi_classic_max_size", 6);
user_pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);

// PREF: smoother font
// [1] https://reddit.com/r/firefox/comments/wvs04y/windows_11_firefox_v104_font_rendering_different/?context=3
user_pref("gfx.webrender.quality.force-subpixel-aa-where-possible", true);

// PREF: allow websites to ask you for your location
user_pref("permissions.default.geo", 0);

// PREF: enable GPU-accelerated Canvas2D [WINDOWS]
user_pref("gfx.canvas.accelerated", true);


// Search engine configuration is now handled by policies.json
// Keeping only essential search-related preferences that aren't covered by policies

// Private browsing search engine settings
user_pref("browser.search.separatePrivateDefault", false);  // Use same engine in private windows
user_pref("browser.search.separatePrivateDefault.ui.enabled", true);  // Show UI option


/****************************************************************************
 * SECTION: TRANSLATIONS                                                   *
****************************************************************************/

// PREF: Firefox Translations [FF118+]
// Automated translation of web content is done locally in Firefox, so that
// the text being translated does not leave your machine.
// [ABOUT] Visit about:translations to translate your own text as well.
// [1] https://blog.mozilla.org/en/mozilla/local-translation-add-on-project-bergamot/
// [2] https://blog.nightly.mozilla.org/2023/06/01/firefox-translations-and-other-innovations-these-weeks-in-firefox-issue-139/
// [3] https://www.ghacks.net/2023/08/02/mozilla-firefox-117-beta-brings-an-automatic-language-translator-for-websites-and-it-works-offline/
user_pref("browser.translations.enable", true); // DEFAULT
user_pref("browser.translations.autoTranslate", true);
