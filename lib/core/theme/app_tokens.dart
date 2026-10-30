import 'package:flutter/material.dart';

/// The house design tokens, taken from the Shop module.
///
/// Shop was built first and its conventions are the ones the app is judged on,
/// so they are the house style rather than one module's taste. This file only
/// names values Shop already uses — it changes nothing there — and exists so
/// the other modules have a single place to read them from instead of
/// re-picking a palette and drifting apart again.
///
/// Not folded into [AppColors] on purpose: that holds the five brand colours
/// the Material theme is seeded from, while these are surface, border and
/// status decisions that only the module widgets care about.
class AppTokens {
  const AppTokens._();

  // ── Surfaces ──

  /// Page background behind cards. Shop's dashboard and profile both sit on
  /// this rather than on white, which is what makes the white cards read as
  /// cards.
  static const Color pageBackground = Color(0xFFF7F8FA);

  /// Card and sheet fill.
  static const Color surface = Colors.white;

  /// Inset fill for a panel inside a card — a metadata grid, a note block.
  static const Color surfaceSunken = Color(0xFFF9FAFB);

  /// Fill for inputs and tappable neutral chips.
  static const Color fieldFill = Color(0xFFF8FAFC);

  /// Neutral tile behind a thumbnail or a leading glyph.
  static const Color tile = Color(0xFFF4F5F7);

  /// Tint behind a selected row.
  static const Color surfaceSelected = Color(0xFFF8FAFF);

  // ── Borders ──

  /// Default card border.
  static const Color border = Color(0xFFE8E9EC);

  /// Border on inputs, chips and larger panels.
  static const Color borderField = Color(0xFFE5E7EB);

  /// Border on a neutral panel sitting on [fieldFill].
  static const Color borderPanel = Color(0xFFE2E8F0);

  /// Hairline divider inside a card, between metrics.
  static const Color divider = Color(0xFFF3F4F6);

  /// Divider between sections of a screen.
  static const Color dividerStrong = Color(0xFFF0F1F3);

  // ── Text ──

  /// Body text that is neither primary nor secondary — a card title.
  static const Color tertiaryText = Color(0xFF4B5563);

  /// Placeholder and empty-state text.
  static const Color mutedText = Color(0xFF9CA3AF);

  /// Empty-state detail, one step fainter than [mutedText].
  static const Color faintText = Color(0xFFBFC4CE);

  // ── Interaction ──

  /// The blue Shop uses for selection, links and the active state.
  ///
  /// Deliberately not `AppColors.primary` (#1F4ED8): that is the brand seed
  /// the Material theme is built from, and every interactive surface in Shop
  /// uses this slightly lighter blue instead.
  static const Color action = Color(0xFF2563EB);

  /// Soft ground under an [action] icon or an active pill.
  static const Color actionSoft = Color(0xFFEBF0FF);

  /// Soft ground for an icon tile, one step cooler than [actionSoft].
  static const Color actionTile = Color(0xFFEFF6FF);

  /// Dark fill for the primary FAB and selected filter pills.
  static const Color inkFill = Color(0xFF1E3A5F);

  // ── Radii ──

  /// Card and sheet corner.
  static const double radiusCard = 16;

  /// Row, input and chip-group corner.
  static const double radiusRow = 14;

  /// Input and medium control corner.
  static const double radiusField = 12;

  /// Small chip, icon tile and pill corner.
  static const double radiusChip = 10;

  // ── Status pairs ──
  //
  // Shop pairs a soft background with a saturated icon, Tailwind 50/500 style.
  // Keeping them as pairs is what stops a green icon landing on an orange
  // ground three screens later.

  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF15803D);

  /// The deeper green Shop uses for a confirming action, as opposed to a
  /// success *state*.
  static const Color successStrong = Color(0xFF16A34A);

  /// Danger state — a rejected booking, a cancelled order.
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);

  /// Destructive *action* — the Delete button. One step darker than [danger],
  /// which is how Shop separates "this went wrong" from "this will remove
  /// something".
  static const Color destructive = Color(0xFFDC2626);
  static const Color destructiveSoft = Color(0xFFFEF2F2);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningText = Color(0xFF92400E);

  /// In-progress — on the way, handover.
  static const Color progress = Color(0xFFF97316);
  static const Color progressSoft = Color(0xFFFFEDD5);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoSoft = Color(0xFFEFF6FF);

  static const Color accentViolet = Color(0xFF8B5CF6);
  static const Color accentVioletSoft = Color(0xFFF5F3FF);

  /// The deeper violet on the dashboard hero's earnings KPI.
  static const Color earnings = Color(0xFF7C3AED);
  static const Color earningsSoft = Color(0xFFF3EEFF);

  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealSoft = Color(0xFFCCFBF1);

  static const Color positive = Color(0xFF10B981);
  static const Color positiveSoft = Color(0xFFECFDF5);

  /// Open-state green, used on the store/availability strip.
  static const Color openFill = Color(0xFFF0FDF4);
  static const Color openBorder = Color(0xFFBBF7D0);
  static const Color openText = Color(0xFF166534);

  /// Closed-state red, the counterpart to the open trio.
  static const Color closedFill = Color(0xFFFEF2F2);
  static const Color closedBorder = Color(0xFFFECACA);
  static const Color closedText = Color(0xFF991B1B);
}
