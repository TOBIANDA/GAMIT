@tool
extends Node2D

const COLOR_VOID            = Color(0.12, 0.13, 0.15, 1.0)

const COLOR_ASPHALT         = Color(0.22, 0.23, 0.25, 1.0)
const COLOR_ASPHALT_DARK    = Color(0.18, 0.19, 0.21, 1.0)
const COLOR_CURB_LINE       = Color(0.55, 0.58, 0.62, 0.85)
const COLOR_LANE_DASH       = Color(0.85, 0.88, 0.92, 0.80)
const COLOR_SIDEWALK        = Color(0.42, 0.44, 0.47, 1.0)
const COLOR_SIDEWALK_BEVEL  = Color(0.28, 0.30, 0.33, 1.0)

const COLOR_ROOM_STONE_A    = Color(0.76, 0.74, 0.69, 1.0)
const COLOR_ROOM_STONE_B    = Color(0.68, 0.67, 0.64, 1.0)
const COLOR_ROOM_OCHRE      = Color(0.74, 0.58, 0.42, 1.0)
const COLOR_ROOM_DARK       = Color(0.16, 0.17, 0.20, 1.0)
const COLOR_ROOM_RUG        = Color(0.28, 0.16, 0.24, 1.0)

const COLOR_PARQUET_WOOD    = Color(0.56, 0.38, 0.24, 1.0)
const COLOR_PARQUET_DARK    = Color(0.44, 0.28, 0.18, 1.0)
const COLOR_RUG_RED         = Color(0.62, 0.15, 0.18, 1.0)
const COLOR_RUG_GOLD        = Color(0.88, 0.72, 0.28, 1.0)
const COLOR_CORKBOARD       = Color(0.76, 0.60, 0.42, 1.0)

const COLOR_HOSPITAL_TILE   = Color(0.88, 0.94, 0.96, 1.0)
const COLOR_HOSPITAL_GROUT  = Color(0.65, 0.76, 0.82, 0.70)
const COLOR_MED_RED         = Color(0.85, 0.20, 0.20, 1.0)
const COLOR_STEEL_LIGHT     = Color(0.78, 0.82, 0.86, 1.0)
const COLOR_STEEL_DARK      = Color(0.48, 0.52, 0.58, 1.0)
const COLOR_ECG_GREEN       = Color(0.20, 0.95, 0.45, 1.0)
const COLOR_DARKROOM_RED    = Color(0.95, 0.15, 0.15, 0.35)

const COLOR_PLAZA_TILES     = Color(0.72, 0.70, 0.65, 1.0)
const COLOR_PLAZA_TILE_LINE = Color(0.58, 0.56, 0.52, 0.60)
const COLOR_GRASS           = Color(0.45, 0.55, 0.22, 1.0)
const COLOR_TREE_DARK       = Color(0.24, 0.32, 0.14, 1.0)
const COLOR_TREE_LIGHT      = Color(0.38, 0.48, 0.20, 1.0)
const COLOR_HELIPAD_RING    = Color(0.92, 0.78, 0.22, 1.0)

const COLOR_DESK_WOOD       = Color(0.52, 0.44, 0.36, 1.0)
const COLOR_DESK_RIM        = Color(0.24, 0.20, 0.16, 1.0)
const COLOR_WALL_LINE       = Color(0.10, 0.11, 0.13, 1.0)

const COLOR_TRACK_BALLAST   = Color(0.20, 0.21, 0.23, 1.0)
const COLOR_TRACK_RAIL      = Color(0.70, 0.74, 0.80, 1.0)
const COLOR_TRACK_TIE       = Color(0.38, 0.33, 0.28, 1.0)

const WT = 6.0
var tex_hospital: Texture2D
var tex_police: Texture2D
var tex_gedung: Texture2D
var tex_rumah_mc: Texture2D
var tex_rumah_depan: Texture2D
var tex_rumah_belakang: Texture2D
var tex_rumah_samping: Texture2D
var tex_pagar: Texture2D
var tex_pagar_samping: Texture2D
var tex_pintu_pagar: Texture2D
var tex_telepon: Texture2D

@export_group("1. Pagar Depan Kiri")
@export var pagar_kiri_geser_x: float = 0.0:
	set(val):
		pagar_kiri_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kiri_geser_y: float = 0.0:
	set(val):
		pagar_kiri_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kiri_lebar: float = 62.0:
	set(val):
		pagar_kiri_lebar = 62.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_kiri_skala: float = 1.0:
	set(val):
		pagar_kiri_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("2. Pintu Pagar Tengah")
@export var pintu_pagar_geser_x: float = 0.0:
	set(val):
		pintu_pagar_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pintu_pagar_geser_y: float = 0.0:
	set(val):
		pintu_pagar_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pintu_pagar_lebar: float = 32.0:
	set(val):
		pintu_pagar_lebar = 32.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pintu_pagar_skala: float = 1.0:
	set(val):
		pintu_pagar_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("3. Pagar Depan Kanan")
@export var pagar_kanan_geser_x: float = 0.0:
	set(val):
		pagar_kanan_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kanan_geser_y: float = 0.0:
	set(val):
		pagar_kanan_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kanan_lebar: float = 62.0:
	set(val):
		pagar_kanan_lebar = 62.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_kanan_skala: float = 1.0:
	set(val):
		pagar_kanan_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("4. Pagar Belakang (Atas)")
@export var pagar_belakang_geser_x: float = 0.0:
	set(val):
		pagar_belakang_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_belakang_geser_y: float = 0.0:
	set(val):
		pagar_belakang_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_belakang_gap_panel: float = 0.0:
	set(val):
		pagar_belakang_gap_panel = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_belakang_panel_lebar: float = 52.0:
	set(val):
		pagar_belakang_panel_lebar = 52.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_belakang_skala: float = 1.0:
	set(val):
		pagar_belakang_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("5. Pagar Samping (Vertikal) & Gap Sudut")
@export var pagar_samping_kiri_geser_x: float = 0.0:
	set(val):
		pagar_samping_kiri_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_kanan_geser_x: float = 0.0:
	set(val):
		pagar_samping_kanan_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_geser_y: float = 0.0:
	set(val):
		pagar_samping_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var gap_sudut_atas_samping: float = 0.0:
	set(val):
		gap_sudut_atas_samping = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_tinggi: float = 146.0:
	set(val):
		pagar_samping_tinggi = 146.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_samping_lebar: float = 12.0:
	set(val):
		pagar_samping_lebar = 12.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_samping_jumlah_panel: int = 2:
	set(val):
		pagar_samping_jumlah_panel = 2 if (val == null or val <= 0) else int(val)
		queue_redraw()
@export var pagar_samping_gap_panel: float = 0.0:
	set(val):
		pagar_samping_gap_panel = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_samping_skala: float = 1.0:
	set(val):
		pagar_samping_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("6. Stasiun Telepon Umum")
@export var telepon_lebar: float = 48.0:
	set(val):
		telepon_lebar = 48.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var telepon_tinggi: float = 72.0:
	set(val):
		telepon_tinggi = 72.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var telepon_skala: float = 1.0:
	set(val):
		telepon_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("7. Kantor Polisi (Police Station)")
@export var polisi_geser_x: float = 0.0:
	set(val):
		polisi_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var polisi_geser_y: float = 0.0:
	set(val):
		polisi_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var polisi_lebar: float = 341.0:
	set(val):
		polisi_lebar = 341.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var polisi_tinggi: float = 350.0:
	set(val):
		polisi_tinggi = 350.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var polisi_skala: float = 1.0:
	set(val):
		polisi_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("8. Rumah Sakit (Hospital)")
@export var rs_geser_x: float = 0.0:
	set(val):
		rs_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var rs_geser_y: float = 0.0:
	set(val):
		rs_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var rs_lebar: float = 585.0:
	set(val):
		rs_lebar = 585.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rs_tinggi: float = 300.0:
	set(val):
		rs_tinggi = 300.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rs_skala: float = 1.0:
	set(val):
		rs_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("9. Stasiun Kereta (Train Station)")
@export var stasiun_geser_x: float = 0.0:
	set(val):
		stasiun_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var stasiun_geser_y: float = 0.0:
	set(val):
		stasiun_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var stasiun_lebar: float = 300.0:
	set(val):
		stasiun_lebar = 300.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var stasiun_tinggi: float = 621.0:
	set(val):
		stasiun_tinggi = 621.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var stasiun_skala: float = 1.0:
	set(val):
		stasiun_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("10. Rumah Atas (11 Rumah Warga)")
@export var rumah_atas_geser_x: float = 0.0:
	set(val):
		rumah_atas_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var rumah_atas_geser_y: float = 0.0:
	set(val):
		rumah_atas_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var rumah_atas_lebar: float = 132.0:
	set(val):
		rumah_atas_lebar = 132.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rumah_atas_tinggi: float = 116.0:
	set(val):
		rumah_atas_tinggi = 116.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rumah_atas_skala: float = 1.0:
	set(val):
		rumah_atas_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("11. Rumah Tenggara (3 Rumah Warga SE)")
@export var rumah_se_geser_x: float = 0.0:
	set(val):
		rumah_se_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var rumah_se_geser_y: float = 0.0:
	set(val):
		rumah_se_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var rumah_se_lebar: float = 132.0:
	set(val):
		rumah_se_lebar = 132.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rumah_se_tinggi: float = 116.0:
	set(val):
		rumah_se_tinggi = 116.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rumah_se_skala: float = 1.0:
	set(val):
		rumah_se_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

# Legacy compatibility properties (Rumah Belakang replaced by WTC South District)
var rumah_belakang_geser_x: float = 0.0
var rumah_belakang_geser_y: float = 0.0
var rumah_belakang_lebar: float = 220.0
var rumah_belakang_tinggi: float = 175.0
var rumah_belakang_skala: float = 1.0

@export_group("13. Dua Rumah Blok NE (East Complex)")
@export var rumah_ne_base_x: float = 1652.0:
	set(val):
		rumah_ne_base_x = 1652.0 if val == null else float(val)
		queue_redraw()
@export var rumah_ne_base_y: float = 358.0:
	set(val):
		rumah_ne_base_y = 358.0 if val == null else float(val)
		queue_redraw()
@export var rumah_ne_jarak: float = 182.0:
	set(val):
		rumah_ne_jarak = 182.0 if val == null else float(val)
		queue_redraw()
@export var rumah_ne_geser_x: float = 0.0:
	set(val):
		rumah_ne_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var rumah_ne_geser_y: float = 0.0:
	set(val):
		rumah_ne_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var rumah_ne_lebar: float = 132.0:
	set(val):
		rumah_ne_lebar = 132.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rumah_ne_tinggi: float = 116.0:
	set(val):
		rumah_ne_tinggi = 116.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var rumah_ne_skala: float = 1.0:
	set(val):
		rumah_ne_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

func get_ne_house_positions() -> Array[Vector2]:
	var bx = (rumah_ne_base_x if rumah_ne_base_x != null else 1652.0)
	var by = (rumah_ne_base_y if rumah_ne_base_y != null else 358.0)
	var step = (rumah_ne_jarak if rumah_ne_jarak != null else 182.0)
	return [Vector2(bx, by), Vector2(bx + step, by)]

# Legacy compatibility properties (Morgue Plaza replaced by WTC North Financial District)
var morgue_geser_x: float = 0.0
var morgue_geser_y: float = 0.0
var morgue_lebar: float = 380.0
var morgue_tinggi: float = 225.0
var morgue_skala: float = 1.0

@export_group("15. Pembatas Kuning Kereta (Platform Yellow Line)")
@export var pembatas_kuning_lebar: float = 20.0:
	set(val):
		pembatas_kuning_lebar = 20.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pembatas_kuning_geser_x: float = 0.0:
	set(val):
		pembatas_kuning_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pembatas_kuning_geser_y: float = 0.0:
	set(val):
		pembatas_kuning_geser_y = 0.0 if val == null else float(val)
		queue_redraw()

@export_group("16. Pagar Kereta & Rel (Train / Station Fence)")
@export var pagar_kereta_tampilkan: bool = true:
	set(val):
		pagar_kereta_tampilkan = val
		queue_redraw()
@export var pagar_kereta_geser_x: float = 0.0:
	set(val):
		pagar_kereta_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kereta_geser_y: float = 0.0:
	set(val):
		pagar_kereta_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_kereta_tinggi: float = 621.0:
	set(val):
		pagar_kereta_tinggi = 621.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_kereta_skala: float = 1.0:
	set(val):
		pagar_kereta_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("17. Pagar Kantor Polisi (Police Fence)")
@export var pagar_polisi_tampilkan: bool = false:
	set(val):
		pagar_polisi_tampilkan = val
		queue_redraw()
@export var pagar_polisi_geser_x: float = 0.0:
	set(val):
		pagar_polisi_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_polisi_geser_y: float = 0.0:
	set(val):
		pagar_polisi_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_polisi_lebar: float = 290.0:
	set(val):
		pagar_polisi_lebar = 290.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_polisi_skala: float = 1.0:
	set(val):
		pagar_polisi_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("18. Pagar Rumah Sakit (Hospital Fence)")
@export var pagar_rs_tampilkan: bool = false:
	set(val):
		pagar_rs_tampilkan = val
		queue_redraw()
@export var pagar_rs_geser_x: float = 0.0:
	set(val):
		pagar_rs_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_rs_geser_y: float = 0.0:
	set(val):
		pagar_rs_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var pagar_rs_lebar: float = 585.0:
	set(val):
		pagar_rs_lebar = 585.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var pagar_rs_skala: float = 1.0:
	set(val):
		pagar_rs_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

const GEDUNG_SRC_RECT := Rect2(1620, 822, 951, 2031)
const GEDUNG_ASPECT_RATIO := 2031.0 / 951.0 # ~2.13565

@export_group("19. Gedung-Gedung Blok NW (North-West Complex)")
@export var gedung_nw_tampilkan: bool = true:
	set(val):
		gedung_nw_tampilkan = val
		queue_redraw()
@export var gedung_nw_kolom: int = 4:
	set(val):
		gedung_nw_kolom = max(1, val)
		queue_redraw()
@export var gedung_nw_baris: int = 2:
	set(val):
		gedung_nw_baris = max(1, val)
		queue_redraw()
@export var gedung_nw_skala: float = 1.0:
	set(val):
		gedung_nw_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_nw_lebar_dasar: float = 84.0:
	set(val):
		gedung_nw_lebar_dasar = 84.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_nw_jarak_x: float = 24.0:
	set(val):
		gedung_nw_jarak_x = 24.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_jarak_y: float = 160.0:
	set(val):
		gedung_nw_jarak_y = 160.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_zigzag: bool = true:
	set(val):
		gedung_nw_zigzag = val
		queue_redraw()
@export var gedung_nw_zigzag_offset: float = 14.0:
	set(val):
		gedung_nw_zigzag_offset = 14.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_depth_tint: bool = true:
	set(val):
		gedung_nw_depth_tint = val
		queue_redraw()
@export var gedung_nw_depth_shadow: bool = true:
	set(val):
		gedung_nw_depth_shadow = val
		queue_redraw()
@export var gedung_nw_rooftop_props: bool = true:
	set(val):
		gedung_nw_rooftop_props = val
		queue_redraw()
@export var gedung_nw_geser_x: float = 0.0:
	set(val):
		gedung_nw_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_geser_y: float = 0.0:
	set(val):
		gedung_nw_geser_y = 0.0 if val == null else float(val)
		queue_redraw()

@export_group("19b. Halaman Rumput & Kolam Renang NW")
@export var gedung_nw_rumput_tampilkan: bool = true:
	set(val):
		gedung_nw_rumput_tampilkan = val
		queue_redraw()
@export var gedung_nw_kolam_tampilkan: bool = true:
	set(val):
		gedung_nw_kolam_tampilkan = val
		queue_redraw()
@export var gedung_nw_kolam_x: float = 175.0:
	set(val):
		gedung_nw_kolam_x = 175.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_kolam_y: float = 692.0:
	set(val):
		gedung_nw_kolam_y = 692.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_kolam_lebar: float = 166.0:
	set(val):
		gedung_nw_kolam_lebar = 166.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_nw_kolam_tinggi: float = 68.0:
	set(val):
		gedung_nw_kolam_tinggi = 68.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

@export_group("19c. Gedung Benjolan Persegi NW")
@export var gedung_benjolan_tampilkan: bool = true:
	set(val):
		gedung_benjolan_tampilkan = val
		queue_redraw()
@export var gedung_benjolan_skala: float = 1.0:
	set(val):
		gedung_benjolan_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_benjolan_geser_x: float = 0.0:
	set(val):
		gedung_benjolan_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var gedung_benjolan_geser_y: float = 0.0:
	set(val):
		gedung_benjolan_geser_y = 0.0 if val == null else float(val)
		queue_redraw()

# Backward compatibility alias
var gedung_polisi_tampilkan: bool:
	get: return gedung_nw_tampilkan
	set(val): gedung_nw_tampilkan = val
var gedung_polisi_skala: float:
	get: return gedung_nw_skala
	set(val): gedung_nw_skala = val
var gedung_polisi_geser_x: float:
	get: return gedung_nw_geser_x
	set(val): gedung_nw_geser_x = val
var gedung_polisi_geser_y: float:
	get: return gedung_nw_geser_y
	set(val): gedung_nw_geser_y = val

func get_nw_gedung_rects() -> Array[Rect2]:
	var sk: float = 1.0 if (gedung_nw_skala == null or gedung_nw_skala <= 0.0) else float(gedung_nw_skala)
	var gx: float = (gedung_nw_geser_x if gedung_nw_geser_x != null else 0.0)
	var gy: float = (gedung_nw_geser_y if gedung_nw_geser_y != null else 0.0)
	var cols: int = max(1, gedung_nw_kolom if gedung_nw_kolom != null else 4)
	var rows: int = max(1, gedung_nw_baris if gedung_nw_baris != null else 3)
	
	var base_w: float = (gedung_nw_lebar_dasar if (gedung_nw_lebar_dasar != null and gedung_nw_lebar_dasar > 0.0) else 96.0) * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	
	var total_area_w: float = 516.0
	var step_x: float = (gedung_nw_jarak_x if gedung_nw_jarak_x != null else 28.0) * sk
	var step_y: float = (gedung_nw_jarak_y if gedung_nw_jarak_y != null else 62.0) * sk
	
	var total_grid_w: float = float(cols) * base_w + float(cols - 1) * step_x
	var start_x: float = (total_area_w - total_grid_w) * 0.5
	var start_y: float = 328.0
	
	var stagger: float = (gedung_nw_zigzag_offset if (gedung_nw_zigzag and gedung_nw_zigzag_offset != null) else 0.0) * sk * 0.5
	
	var rects: Array[Rect2] = []
	for r in range(rows):
		var cur_y: float = start_y + float(r) * step_y + gy
		var row_offset_x: float = (-stagger if (r % 2 == 0) else stagger)
		for c in range(cols):
			var cur_x: float = start_x + float(c) * (base_w + step_x) + gx + row_offset_x
			rects.append(Rect2(cur_x, cur_y, base_w, base_h))
	return rects

func get_nw_gedung_columns() -> Array[Rect2]:
	var sk: float = 1.0 if (gedung_nw_skala == null or gedung_nw_skala <= 0.0) else float(gedung_nw_skala)
	var gx: float = (gedung_nw_geser_x if gedung_nw_geser_x != null else 0.0)
	var gy: float = (gedung_nw_geser_y if gedung_nw_geser_y != null else 0.0)
	var cols: int = max(1, gedung_nw_kolom if gedung_nw_kolom != null else 4)
	var rows: int = max(1, gedung_nw_baris if gedung_nw_baris != null else 3)
	
	var base_w: float = (gedung_nw_lebar_dasar if (gedung_nw_lebar_dasar != null and gedung_nw_lebar_dasar > 0.0) else 96.0) * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var total_area_w: float = 516.0
	var step_x: float = (gedung_nw_jarak_x if gedung_nw_jarak_x != null else 28.0) * sk
	var step_y: float = (gedung_nw_jarak_y if gedung_nw_jarak_y != null else 62.0) * sk
	var total_grid_w: float = float(cols) * base_w + float(cols - 1) * step_x
	var start_x: float = (total_area_w - total_grid_w) * 0.5
	var start_y: float = 328.0
	var total_col_h: float = float(rows - 1) * step_y + base_h
	
	var stagger: float = (gedung_nw_zigzag_offset if (gedung_nw_zigzag and gedung_nw_zigzag_offset != null) else 0.0) * sk * 0.5
	
	var col_rects: Array[Rect2] = []
	for c in range(cols):
		var cur_x: float = start_x + float(c) * (base_w + step_x) + gx - stagger
		var col_w: float = base_w + stagger * 2.0
		col_rects.append(Rect2(cur_x, start_y + gy, col_w, total_col_h))
	return col_rects

func get_benjolan_gedung_rect() -> Rect2:
	var sk: float = 1.0 if (gedung_benjolan_skala == null or gedung_benjolan_skala <= 0.0) else float(gedung_benjolan_skala)
	var gx: float = (gedung_benjolan_geser_x if gedung_benjolan_geser_x != null else 0.0)
	var gy: float = (gedung_benjolan_geser_y if gedung_benjolan_geser_y != null else 0.0)
	var base_w: float = (gedung_nw_lebar_dasar if (gedung_nw_lebar_dasar != null and gedung_nw_lebar_dasar > 0.0) else 84.0) * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var bx: float = (192.0 - base_w) * 0.5 + gx
	var by: float = 922.0 - base_h + gy
	return Rect2(bx, by, base_w, base_h)

func get_nw_kolam_water_rect() -> Rect2:
	var kx: float = (gedung_nw_kolam_x if gedung_nw_kolam_x != null else 175.0)
	var ky: float = (gedung_nw_kolam_y if gedung_nw_kolam_y != null else 692.0)
	var kw: float = (gedung_nw_kolam_lebar if (gedung_nw_kolam_lebar != null and gedung_nw_kolam_lebar > 0.0) else 166.0)
	var kh: float = (gedung_nw_kolam_tinggi if (gedung_nw_kolam_tinggi != null and gedung_nw_kolam_tinggi > 0.0) else 68.0)
	return Rect2(kx, ky, kw, kh)

func _draw_swimming_pool(rect: Rect2) -> void:
	# 1. Dek / Teras Paving Sekitar Kolam (Pool Deck)
	var deck_pad_x := 16.0
	var deck_pad_y := 10.0
	var deck_rect := Rect2(rect.position.x - deck_pad_x, rect.position.y - deck_pad_y, rect.size.x + deck_pad_x * 2.0, rect.size.y + deck_pad_y * 2.0)
	
	# Bayangan jatuh dek kolam di atas rumput
	draw_rect(Rect2(deck_rect.position.x - 2, deck_rect.position.y - 2, deck_rect.size.x + 4, deck_rect.size.y + 6), Color(0, 0, 0, 0.22), true)
	# Lantai batu travertine/sandstone
	draw_rect(deck_rect, Color(0.86, 0.84, 0.78), true)
	
	# Garis paving kotak-kotak halus di dek
	var grid_step := 16.0
	for px in range(int(deck_rect.position.x), int(deck_rect.end.x), int(grid_step)):
		draw_line(Vector2(px, deck_rect.position.y), Vector2(px, deck_rect.end.y), Color(0.76, 0.74, 0.68, 0.6), 1.0)
	for py in range(int(deck_rect.position.y), int(deck_rect.end.y), int(grid_step)):
		draw_line(Vector2(deck_rect.position.x, py), Vector2(deck_rect.end.x, py), Color(0.76, 0.74, 0.68, 0.6), 1.0)

	# 2. Batu Coping / Tepi Kolam (Pool Coping Border)
	var coping_rect := Rect2(rect.position.x - 4, rect.position.y - 4, rect.size.x + 8, rect.size.y + 8)
	draw_rect(coping_rect, Color(0.95, 0.94, 0.90), true)
	draw_rect(coping_rect, Color(0.68, 0.66, 0.62), false, 1.5)

	# 3. Bayangan Kedalaman Dinding Kolam
	draw_rect(rect, Color(0.12, 0.40, 0.58), true)

	# 4. Air Kolam (Gradien Kedalaman: Dangkal Cyan -> Dalam Biru Tua)
	var water_h := rect.size.y
	draw_rect(Rect2(rect.position.x + 2, rect.position.y + 2, rect.size.x - 4, water_h * 0.45), Color(0.24, 0.68, 0.86), true)
	draw_rect(Rect2(rect.position.x + 2, rect.position.y + water_h * 0.45, rect.size.x - 4, water_h * 0.55 - 2), Color(0.16, 0.54, 0.74), true)

	# 5. Garis Jalur Renang / Tegel Kolam
	var lane_y1 := rect.position.y + water_h * 0.33
	var lane_y2 := rect.position.y + water_h * 0.66
	for lx in range(int(rect.position.x + 12), int(rect.end.x - 12), 16):
		draw_line(Vector2(lx, lane_y1), Vector2(lx + 8, lane_y1), Color(0.12, 0.38, 0.55, 0.5), 2.0)
		draw_line(Vector2(lx, lane_y2), Vector2(lx + 8, lane_y2), Color(0.12, 0.38, 0.55, 0.5), 2.0)

	# 6. Gelombang / Kilauan Cahaya Air (Water Shimmer)
	draw_line(Vector2(rect.position.x + 20, rect.position.y + 14), Vector2(rect.position.x + 55, rect.position.y + 14), Color(1.0, 1.0, 1.0, 0.38), 1.5)
	draw_line(Vector2(rect.position.x + 80, rect.position.y + 24), Vector2(rect.position.x + 130, rect.position.y + 24), Color(1.0, 1.0, 1.0, 0.35), 1.5)
	draw_line(Vector2(rect.position.x + 40, rect.position.y + 45), Vector2(rect.position.x + 90, rect.position.y + 45), Color(1.0, 1.0, 1.0, 0.28), 1.5)
	draw_line(Vector2(rect.position.x + 110, rect.position.y + 60), Vector2(rect.position.x + 155, rect.position.y + 60), Color(1.0, 1.0, 1.0, 0.32), 1.5)

	# 7. Tangga Stainless Kolam Renang (Pool Ladder di pojok kanan atas)
	var lad_x := rect.end.x - 22.0
	var lad_y := rect.position.y - 4.0
	draw_line(Vector2(lad_x, lad_y), Vector2(lad_x, lad_y + 14), Color(0.92, 0.94, 0.98), 2.0)
	draw_line(Vector2(lad_x + 8, lad_y), Vector2(lad_x + 8, lad_y + 14), Color(0.92, 0.94, 0.98), 2.0)
	draw_line(Vector2(lad_x, lad_y + 6), Vector2(lad_x + 8, lad_y + 6), Color(0.80, 0.85, 0.90), 1.5)
	draw_line(Vector2(lad_x, lad_y + 11), Vector2(lad_x + 8, lad_y + 11), Color(0.80, 0.85, 0.90), 1.5)

	# 8. Kursi Santai Kolam (Sun Loungers di sisi kanan dek)
	var chair_x := deck_rect.end.x - 14.0
	for ci_idx in range(2):
		var chair_y := deck_rect.position.y + 14.0 + float(ci_idx) * 30.0
		draw_rect(Rect2(chair_x - 8, chair_y, 10, 22), Color(0.55, 0.38, 0.22), true)
		draw_rect(Rect2(chair_x - 7, chair_y + 1, 8, 20), Color(0.96, 0.96, 0.96), true)
		draw_line(Vector2(chair_x - 7, chair_y + 6), Vector2(chair_x + 1, chair_y + 6), Color(0.2, 0.55, 0.8), 2.0)
		draw_line(Vector2(chair_x - 7, chair_y + 14), Vector2(chair_x + 1, chair_y + 14), Color(0.2, 0.55, 0.8), 2.0)
		draw_rect(Rect2(chair_x - 6, chair_y + 2, 6, 5), Color(0.2, 0.55, 0.8), true)

	# 9. Payung Pantai / Peneduh (Beach Umbrella di pojok atas kanan dek dekat kursi)
	var umb_center := Vector2(deck_rect.end.x - 8.0, deck_rect.position.y + 12.0)
	draw_circle(umb_center + Vector2(2, 3), 10.0, Color(0, 0, 0, 0.22))
	draw_circle(umb_center, 10.0, Color(0.96, 0.82, 0.20))
	for w_angle in range(0, 360, 90):
		var rad := deg_to_rad(float(w_angle))
		draw_line(umb_center, umb_center + Vector2(cos(rad), sin(rad)) * 10.0, Color(0.96, 0.96, 0.96), 2.5)
	draw_circle(umb_center, 2.5, Color(0.85, 0.45, 0.15))

func _draw_rooftop_props_to(ci: CanvasItem, b_rect: Rect2, seed_idx: int) -> void:
	if not is_instance_valid(ci):
		return
	var roof_top: float = b_rect.position.y
	var roof_w: float = b_rect.size.x
	
	# 1. AC Outdoor Unit (di sisi kiri atap)
	var ac_x: float = b_rect.position.x + 12.0
	var ac_y: float = roof_top + 12.0
	var ac_w: float = 20.0
	var ac_h: float = 14.0
	ci.draw_rect(Rect2(ac_x, ac_y, ac_w, ac_h), Color(0.76, 0.78, 0.80), true)
	ci.draw_rect(Rect2(ac_x, ac_y, ac_w, ac_h), Color(0.35, 0.38, 0.42), false, 1.0)
	ci.draw_line(Vector2(ac_x + 3, ac_y + 4), Vector2(ac_x + 12, ac_y + 4), Color(0.40, 0.42, 0.45), 1.0)
	ci.draw_line(Vector2(ac_x + 3, ac_y + 7), Vector2(ac_x + 12, ac_y + 7), Color(0.40, 0.42, 0.45), 1.0)
	ci.draw_line(Vector2(ac_x + 3, ac_y + 10), Vector2(ac_x + 12, ac_y + 10), Color(0.40, 0.42, 0.45), 1.0)
	ci.draw_circle(Vector2(ac_x + 15, ac_y + 7), 3.0, Color(0.45, 0.48, 0.50))

	# 2. Water Tank / Toren Air (pada gedung indeks ganjil)
	if seed_idx % 2 == 1:
		var tank_x: float = b_rect.position.x + roof_w - 30.0
		var tank_y: float = roof_top + 8.0
		var tank_w: float = 18.0
		var tank_h: float = 22.0
		ci.draw_line(Vector2(tank_x + 3, tank_y + tank_h), Vector2(tank_x + 3, tank_y + tank_h + 4), Color(0.3, 0.3, 0.35), 1.5)
		ci.draw_line(Vector2(tank_x + tank_w - 3, tank_y + tank_h), Vector2(tank_x + tank_w - 3, tank_y + tank_h + 4), Color(0.3, 0.3, 0.35), 1.5)
		ci.draw_rect(Rect2(tank_x, tank_y, tank_w, tank_h), Color(0.38, 0.58, 0.76), true)
		ci.draw_rect(Rect2(tank_x, tank_y, tank_w, tank_h), Color(0.20, 0.35, 0.50), false, 1.0)
		ci.draw_line(Vector2(tank_x, tank_y + 7), Vector2(tank_x + tank_w, tank_y + 7), Color(0.25, 0.45, 0.60), 1.0)
		ci.draw_line(Vector2(tank_x, tank_y + 14), Vector2(tank_x + tank_w, tank_y + 14), Color(0.25, 0.45, 0.60), 1.0)

	# 3. Tiang Antena Komunikasi + Lampu Merah (pada gedung indeks kelipatan 3)
	if seed_idx % 3 == 0:
		var ant_x: float = b_rect.position.x + roof_w * 0.5
		var ant_y: float = roof_top + 10.0
		ci.draw_line(Vector2(ant_x, ant_y), Vector2(ant_x, ant_y - 14), Color(0.25, 0.28, 0.30), 1.5)
		ci.draw_line(Vector2(ant_x - 4, ant_y - 8), Vector2(ant_x + 4, ant_y - 8), Color(0.25, 0.28, 0.30), 1.0)
		ci.draw_circle(Vector2(ant_x, ant_y - 14), 2.0, Color(1.0, 0.22, 0.22))

@export_group("21. Metropolitan World Trade Center Complex")
@export var wtc_tampilkan: bool = true:
	set(val):
		wtc_tampilkan = val
		queue_redraw()
@export var wtc_twin_skala: float = 1.0:
	set(val):
		wtc_twin_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var wtc_twin_geser_x: float = 0.0:
	set(val):
		wtc_twin_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_twin_geser_y: float = 0.0:
	set(val):
		wtc_twin_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_north_skala: float = 0.95:
	set(val):
		wtc_north_skala = 0.95 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var wtc_north_jumlah: int = 5:
	set(val):
		wtc_north_jumlah = max(1, val)
		queue_redraw()
@export var wtc_north_geser_x: float = 0.0:
	set(val):
		wtc_north_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_north_geser_y: float = 0.0:
	set(val):
		wtc_north_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_south_skala: float = 0.92:
	set(val):
		wtc_south_skala = 0.92 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var wtc_south_geser_x: float = 0.0:
	set(val):
		wtc_south_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_south_geser_y: float = 0.0:
	set(val):
		wtc_south_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_pool_tampilkan: bool = true:
	set(val):
		wtc_pool_tampilkan = val
		queue_redraw()
@export var wtc_pool_geser_x: float = 0.0:
	set(val):
		wtc_pool_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_pool_geser_y: float = 0.0:
	set(val):
		wtc_pool_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var wtc_spire_tampilkan: bool = true:
	set(val):
		wtc_spire_tampilkan = val
		queue_redraw()

# Legacy compatibility properties
var gedung_tengah_tampilkan: bool = false
var gedung_tengah_skala: float = 0.92
var gedung_tengah_jumlah: int = 3
var gedung_tengah_jarak_x: float = 30.0
var gedung_tengah_geser_x: float = 0.0
var gedung_tengah_geser_y: float = 0.0

func get_tengah_gedung_rects() -> Array[Rect2]:
	return []

func get_wtc_north_towers() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	var count: int = max(1, wtc_north_jumlah if wtc_north_jumlah != null else 5)
	var sk: float = 1.0 if (wtc_north_skala == null or wtc_north_skala <= 0.0) else float(wtc_north_skala)
	var base_w: float = 86.0 * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var area_start_x: float = 660.0
	var area_w: float = 856.0
	var total_w: float = float(count) * base_w
	var gap: float = (area_w - total_w) / float(max(1, count - 1))
	var start_y: float = 324.0 + (225.0 - base_h) * 0.5 + (wtc_north_geser_y if wtc_north_geser_y != null else 0.0)
	for i in range(count):
		var cur_x: float = area_start_x + float(i) * (base_w + gap) + (wtc_north_geser_x if wtc_north_geser_x != null else 0.0)
		rects.append(Rect2(cur_x, start_y, base_w, base_h))
	return rects

func get_wtc_twin_towers() -> Array[Rect2]:
	var sk: float = 1.0 if (wtc_twin_skala == null or wtc_twin_skala <= 0.0) else float(wtc_twin_skala)
	var base_w: float = 104.0 * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var gx: float = (wtc_twin_geser_x if wtc_twin_geser_x != null else 0.0)
	var gy: float = (wtc_twin_geser_y if wtc_twin_geser_y != null else 0.0)
	var t1 = Rect2(1075.0 + gx, 712.0 + gy, base_w, base_h)
	var t2 = Rect2(1357.0 + gx, 712.0 + gy, base_w, base_h)
	return [t1, t2]

func get_wtc_memorial_pool_rect() -> Rect2:
	var gx: float = (wtc_pool_geser_x if wtc_pool_geser_x != null else 0.0)
	var gy: float = (wtc_pool_geser_y if wtc_pool_geser_y != null else 0.0)
	return Rect2(1183.0 + gx, 965.0 + gy, 170.0, 110.0)

func get_wtc_south_flank_towers() -> Array[Rect2]:
	var sk: float = 1.0 if (wtc_south_skala == null or wtc_south_skala <= 0.0) else float(wtc_south_skala)
	var base_w: float = 84.0 * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var gx: float = (wtc_south_geser_x if wtc_south_geser_x != null else 0.0)
	var gy: float = (wtc_south_geser_y if wtc_south_geser_y != null else 0.0)
	var t3 = Rect2(1065.0 + gx, 995.0 + gy, base_w, base_h)
	var t4 = Rect2(1387.0 + gx, 995.0 + gy, base_w, base_h)
	return [t3, t4]

func get_rs_gedung_rects() -> Array[Rect2]:
	var sk: float = 1.0 if (gedung_rs_skala == null or gedung_rs_skala <= 0.0) else float(gedung_rs_skala)
	var gx: float = (gedung_rs_geser_x if gedung_rs_geser_x != null else 0.0)
	var gy: float = (gedung_rs_geser_y if gedung_rs_geser_y != null else 0.0)
	var base_w: float = 96.0 * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	# Posisi serasi di sisi kanan taman melingkar RS
	var bx: float = 870.0 + gx
	var by: float = 715.0 + gy
	return [Rect2(bx, by, base_w, base_h)]

@export_group("20. Gedung Samping Rumah Sakit")
@export var gedung_rs_tampilkan: bool = true:
	set(val):
		gedung_rs_tampilkan = val
		queue_redraw()
@export var gedung_rs_geser_x: float = 0.0:
	set(val):
		gedung_rs_geser_x = 0.0 if val == null else float(val)
		queue_redraw()
@export var gedung_rs_geser_y: float = 0.0:
	set(val):
		gedung_rs_geser_y = 0.0 if val == null else float(val)
		queue_redraw()
@export var gedung_rs_lebar: float = 380.0:
	set(val):
		gedung_rs_lebar = 380.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_rs_tinggi: float = 240.0:
	set(val):
		gedung_rs_tinggi = 240.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_rs_skala: float = 1.0:
	set(val):
		gedung_rs_skala = 1.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()

var tex_bed: Texture2D
var tex_karpet: Texture2D
var tex_laci: Texture2D
var tex_lemari: Texture2D

var tex_baskom: Texture2D
var tex_surat: Texture2D
var collision_bodies: Array[StaticBody2D] = []
var nav_region: NavigationRegion2D
var roof_overlay_node: Node2D
var gate_slide_offsets: Dictionary = {}
var player_cached: CharacterBody2D = null
var gate_audio_player: AudioStreamPlayer2D

func _ready() -> void:
	z_index = -1
	_load_textures()
	_setup_gate_audio()
	if not Engine.is_editor_hint():
		_build_all_colliders()
		_setup_navigation_region()
		_spawn_interactive_cars()
		_setup_roof_overlay()
	queue_redraw()

func _setup_gate_audio() -> void:
	gate_audio_player = AudioStreamPlayer2D.new()
	gate_audio_player.name = "GateAudioPlayer"
	var door_stream = load("res://sound/Door Open.mp3")
	if door_stream:
		gate_audio_player.stream = door_stream
		gate_audio_player.max_distance = 600.0
		gate_audio_player.volume_db = -6.0
	add_child(gate_audio_player)

func _play_gate_open_sound(pos: Vector2) -> void:
	if is_instance_valid(gate_audio_player) and gate_audio_player.stream:
		gate_audio_player.global_position = pos
		if not gate_audio_player.playing:
			gate_audio_player.play()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not is_instance_valid(player_cached):
		player_cached = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if not is_instance_valid(player_cached):
			player_cached = get_node_or_null("../Player") as CharacterBody2D

	var needs_redraw := false
	var p_pos := player_cached.global_position if is_instance_valid(player_cached) else Vector2(-9999, -9999)

	# Update posisi geser buka pintu pagar 11 Rumah Atas (Membuka Geser Mulus ke Kiri)
	for i in range(11):
		var sq_x: float = (13.0 + float(i) * 62.0) * 3.0
		var sq_y: float = 36.0
		var gate_center := Vector2(sq_x + 78.0, sq_y + 138.0)
		var key := "top_%d" % i
		var dist := p_pos.distance_to(gate_center)
		var target_slide: float = -28.0 if dist < 50.0 else 0.0
		var cur: float = gate_slide_offsets.get(key, 0.0)
		if cur == 0.0 and target_slide < 0.0:
			_play_gate_open_sound(gate_center)
		var next_val := move_toward(cur, target_slide, delta * 95.0)
		if abs(cur - next_val) > 0.01:
			gate_slide_offsets[key] = next_val
			needs_redraw = true

	# Update posisi geser buka pintu pagar 3 Rumah Tenggara
	var hy_list: Array[float] = [705.0, 880.0, 1055.0]
	for idx in range(3):
		var sq_x: float = 1636.0
		var sq_y: float = hy_list[idx]
		var gate_center := Vector2(sq_x + 78.0, sq_y + 138.0)
		var key := "se_%d" % idx
		var dist := p_pos.distance_to(gate_center)
		var target_slide: float = -28.0 if dist < 50.0 else 0.0
		var cur: float = gate_slide_offsets.get(key, 0.0)
		if cur == 0.0 and target_slide < 0.0:
			_play_gate_open_sound(gate_center)
		var next_val := move_toward(cur, target_slide, delta * 95.0)
		if abs(cur - next_val) > 0.01:
			gate_slide_offsets[key] = next_val
			needs_redraw = true

	# Update posisi geser buka pintu pagar 2 Rumah NE
	var ne_positions_proc = get_ne_house_positions()
	for idx in range(ne_positions_proc.size()):
		var n_pos: Vector2 = ne_positions_proc[idx]
		var gate_center := Vector2(n_pos.x + 78.0, n_pos.y + 138.0)
		var key := "ne_%d" % idx
		var dist := p_pos.distance_to(gate_center)
		var target_slide: float = -28.0 if dist < 50.0 else 0.0
		var cur: float = gate_slide_offsets.get(key, 0.0)
		if cur == 0.0 and target_slide < 0.0:
			_play_gate_open_sound(gate_center)
		var next_val := move_toward(cur, target_slide, delta * 95.0)
		if abs(cur - next_val) > 0.01:
			gate_slide_offsets[key] = next_val
			needs_redraw = true

	if needs_redraw:
		queue_redraw()

class RoofOverlayNode extends Node2D:
	var map: Node2D = null

	# Rasio area atap (bagian atas) vs dinding depan pada perspektif 3/4 top-down.
	# Karakter di depan rumah TIDAK tertutup — hanya yang di belakang/di bawah atap.
	const ROOF_RATIO := 0.72  # 72% atas = atap, 28% bawah = dinding depan (tidak menutup karakter depan)

	func _draw_house_roof(tex: Texture2D, dest: Rect2) -> void:
		if tex == null:
			return
		var tex_size := tex.get_size()
		if tex_size.x <= 0 or tex_size.y <= 0:
			return
		var scale_factor: float = min(dest.size.x / tex_size.x, dest.size.y / tex_size.y)
		var draw_size: Vector2 = tex_size * scale_factor
		var draw_pos: Vector2 = dest.position + (dest.size - draw_size) * 0.5
		var roof_h_px := draw_size.y * ROOF_RATIO
		var src := Rect2(0.0, 0.0, tex_size.x, tex_size.y * ROOF_RATIO)
		draw_texture_rect_region(tex, Rect2(draw_pos, Vector2(draw_size.x, roof_h_px)), src, Color.WHITE)

	func _draw() -> void:
		if not is_instance_valid(map):
			return

		# ── 1. Atap 11 Rumah Atas ──────────────────────────────────────────────
		# Hanya 72% atas (genteng) yang menutupi karakter.
		# 28% bawah (dinding depan/jendela) TIDAK digambar di sini supaya
		# karakter yang berdiri di depan rumah TIDAK tertutup.
		var ra_sk = 1.0 if (map.rumah_atas_skala == null or map.rumah_atas_skala <= 0.0) else float(map.rumah_atas_skala)
		var ra_w = (map.rumah_atas_lebar if (map.rumah_atas_lebar != null and map.rumah_atas_lebar > 0.0) else 132.0) * ra_sk
		var ra_h = (map.rumah_atas_tinggi if (map.rumah_atas_tinggi != null and map.rumah_atas_tinggi > 0.0) else 116.0) * ra_sk
		var ra_gx = (map.rumah_atas_geser_x if map.rumah_atas_geser_x != null else 0.0)
		var ra_gy = (map.rumah_atas_geser_y if map.rumah_atas_geser_y != null else 0.0)
		for i in range(11):
			var sq_x: float = (13.0 + float(i) * 62.0) * 3.0
			var h_tex: Texture2D = map.tex_rumah_mc if i == 6 else map.tex_rumah_depan
			_draw_house_roof(h_tex, Rect2(sq_x + 12 + ra_gx, 36 + 6 + ra_gy, ra_w, ra_h))

		# ── 2. Atap 3 Rumah Tenggara ───────────────────────────────────────────
		var rse_sk = 1.0 if (map.rumah_se_skala == null or map.rumah_se_skala <= 0.0) else float(map.rumah_se_skala)
		var rse_w = (map.rumah_se_lebar if (map.rumah_se_lebar != null and map.rumah_se_lebar > 0.0) else 132.0) * rse_sk
		var rse_h = (map.rumah_se_tinggi if (map.rumah_se_tinggi != null and map.rumah_se_tinggi > 0.0) else 116.0) * rse_sk
		var rse_gx = (map.rumah_se_geser_x if map.rumah_se_geser_x != null else 0.0)
		var rse_gy = (map.rumah_se_geser_y if map.rumah_se_geser_y != null else 0.0)
		for hy in [705.0, 880.0, 1055.0]:
			_draw_house_roof(map.tex_rumah_depan, Rect2(1636 + 12 + rse_gx, hy + 6 + rse_gy, rse_w, rse_h))

		# ── 3. (Rumah Belakang removed for WTC Complex) ────────────────────────

		# ── 3b. Atap 2 Rumah Blok NE ──────────────────────────────────────────
		var rne_sk = 1.0 if (map.rumah_ne_skala == null or map.rumah_ne_skala <= 0.0) else float(map.rumah_ne_skala)
		var rne_w = (map.rumah_ne_lebar if (map.rumah_ne_lebar != null and map.rumah_ne_lebar > 0.0) else 132.0) * rne_sk
		var rne_h = (map.rumah_ne_tinggi if (map.rumah_ne_tinggi != null and map.rumah_ne_tinggi > 0.0) else 116.0) * rne_sk
		var rne_gx = (map.rumah_ne_geser_x if map.rumah_ne_geser_x != null else 0.0)
		var rne_gy = (map.rumah_ne_geser_y if map.rumah_ne_geser_y != null else 0.0)
		for n_pos in map.get_ne_house_positions():
			_draw_house_roof(map.tex_rumah_depan, Rect2(n_pos.x + 12 + rne_gx, n_pos.y + 6 + rne_gy, rne_w, rne_h))

		# ── 4. Kanopi Peron Stasiun (FULL COVER) ──────────────────────────────
		var p1_x := 1860.0 + 125.0
		var warn1_x := 2140.0
		var b_w := 142.0
		var b_h := 245.0
		map._draw_station_building_to(self, Rect2(p1_x + 6, 690 + 8, b_w, b_h))

		var c1_y := 690 + b_h + 20.0
		var c1_h := 621 - b_h - 40.0
		var c1_w := 68.0
		var c1_x := warn1_x - c1_w - 16.0
		map._draw_vertical_canopy_to(self, Rect2(c1_x, c1_y, c1_w, c1_h))

		var c2_w := 68.0
		var c2_h := 571.0
		var c2_x := 2280.0 + 38.0
		var c2_y := 690.0 + 25.0
		map._draw_vertical_canopy_to(self, Rect2(c2_x, c2_y, c2_w, c2_h))

		# ── 5. Atap Gedung-Gedung Blok NW, Benjolan, Plaza Tengah, & Samping RS ──
		if map.gedung_nw_tampilkan and is_instance_valid(map.tex_gedung):
			var nw_rects: Array[Rect2] = map.get_nw_gedung_rects()
			for idx in range(nw_rects.size()):
				var b_rect: Rect2 = nw_rects[idx]
				var r: int = int(floor(float(idx) / float(max(1, map.gedung_nw_kolom))))
				var total_rows: int = max(1, map.gedung_nw_baris)
				var tint: Color = Color.WHITE
				if map.gedung_nw_depth_tint:
					if r == 0 and total_rows > 1:
						tint = Color(0.82, 0.85, 0.92, 1.0)
					elif r < total_rows - 1:
						tint = Color(0.92, 0.94, 0.97, 1.0)
				var roof_h: float = b_rect.size.y * 0.35
				var src_h: float = 2031.0 * 0.35
				var src := Rect2(1620.0, 822.0, 951.0, src_h)
				draw_texture_rect_region(map.tex_gedung, Rect2(b_rect.position, Vector2(b_rect.size.x, roof_h)), src, tint)
				if map.gedung_nw_rooftop_props:
					map._draw_rooftop_props_to(self, b_rect, idx)

		if map.gedung_benjolan_tampilkan and is_instance_valid(map.tex_gedung):
			var bg_rect: Rect2 = map.get_benjolan_gedung_rect()
			var roof_h: float = bg_rect.size.y * 0.35
			var src_h: float = 2031.0 * 0.35
			var src := Rect2(1620.0, 822.0, 951.0, src_h)
			draw_texture_rect_region(map.tex_gedung, Rect2(bg_rect.position, Vector2(bg_rect.size.x, roof_h)), src, Color.WHITE)
			if map.gedung_nw_rooftop_props:
				map._draw_rooftop_props_to(self, bg_rect, 99)

		# ── Atap Kompleks Metropolitan World Trade Center ──────────────────────
		if map.wtc_tampilkan and is_instance_valid(map.tex_gedung):
			# 1. Barisan Gedung Finansial Utara (5 Gedung)
			var north_rects: Array[Rect2] = map.get_wtc_north_towers()
			for idx in range(north_rects.size()):
				var b_rect: Rect2 = north_rects[idx]
				var roof_h: float = b_rect.size.y * 0.35
				var src_h: float = 2031.0 * 0.35
				var src := Rect2(1620.0, 822.0, 951.0, src_h)
				draw_texture_rect_region(map.tex_gedung, Rect2(b_rect.position, Vector2(b_rect.size.x, roof_h)), src, Color.WHITE)
				map._draw_rooftop_props_to(self, b_rect, 10 + idx)

			# 2. Menara Kembar WTC (1 WTC & 2 WTC)
			var twin_rects: Array[Rect2] = map.get_wtc_twin_towers()
			if twin_rects.size() >= 2:
				var t1_rect: Rect2 = twin_rects[0]
				var t2_rect: Rect2 = twin_rects[1]
				
				# Menara 1 (North Tower) + Antena Spire Perak
				var t1_roof_h: float = t1_rect.size.y * 0.35
				var t1_src := Rect2(1620.0, 822.0, 951.0, 2031.0 * 0.35)
				draw_texture_rect_region(map.tex_gedung, Rect2(t1_rect.position, Vector2(t1_rect.size.x, t1_roof_h)), t1_src, Color.WHITE)
				if map.wtc_spire_tampilkan:
					map._draw_wtc_spire_to(self, t1_rect)
				
				# Menara 2 (South Tower) + Dek Observasi Rooftop
				var t2_roof_h: float = t2_rect.size.y * 0.35
				var t2_src := Rect2(1620.0, 822.0, 951.0, 2031.0 * 0.35)
				draw_texture_rect_region(map.tex_gedung, Rect2(t2_rect.position, Vector2(t2_rect.size.x, t2_roof_h)), t2_src, Color.WHITE)
				map._draw_wtc_observation_deck_to(self, t2_rect)

			# 3. Gedung Sayap Selatan (3 WTC & 4 WTC)
			var flank_rects: Array[Rect2] = map.get_wtc_south_flank_towers()
			for idx in range(flank_rects.size()):
				var b_rect: Rect2 = flank_rects[idx]
				var roof_h: float = b_rect.size.y * 0.35
				var src_h: float = 2031.0 * 0.35
				var src := Rect2(1620.0, 822.0, 951.0, src_h)
				draw_texture_rect_region(map.tex_gedung, Rect2(b_rect.position, Vector2(b_rect.size.x, roof_h)), src, Color.WHITE)
				map._draw_rooftop_props_to(self, b_rect, 30 + idx)

		# Atap Gedung Samping Rumah Sakit
		if map.gedung_rs_tampilkan and is_instance_valid(map.tex_gedung):
			var rs_rects: Array[Rect2] = map.get_rs_gedung_rects()
			for idx in range(rs_rects.size()):
				var b_rect: Rect2 = rs_rects[idx]
				var roof_h: float = b_rect.size.y * 0.35
				var src_h: float = 2031.0 * 0.35
				var src := Rect2(1620.0, 822.0, 951.0, src_h)
				draw_texture_rect_region(map.tex_gedung, Rect2(b_rect.position, Vector2(b_rect.size.x, roof_h)), src, Color.WHITE)
				if map.gedung_nw_rooftop_props:
					map._draw_rooftop_props_to(self, b_rect, 80 + idx)


func _setup_roof_overlay() -> void:
	if is_instance_valid(roof_overlay_node):
		roof_overlay_node.queue_free()
	var overlay = RoofOverlayNode.new()
	overlay.name = "BuildingRoofsOverlay"
	overlay.map = self
	overlay.z_as_relative = false
	overlay.z_index = 8 # Render di atas Player (z=0) dan Train (z=5)
	add_child(overlay)
	roof_overlay_node = overlay
	overlay.queue_redraw()

func _spawn_interactive_cars() -> void:
	var car_scene = load("res://scenes/drivable_car.tscn")
	if not is_instance_valid(car_scene):
		return
	
	var car_configs = [
		{"pos": Vector2(1908, 728), "color": Color(0.20, 0.45, 0.78), "is_taxi": false, "name": "Sedan Biru"},
		{"pos": Vector2(1908, 793), "color": Color(0.95, 0.78, 0.15), "is_taxi": true,  "name": "Taksi Kuning"},
		{"pos": Vector2(1908, 858), "color": Color(0.78, 0.80, 0.84), "is_taxi": false, "name": "Sedan Silver"},
		{"pos": Vector2(1908, 1108), "color": Color(0.85, 0.22, 0.20), "is_taxi": false, "name": "Coupe Merah"},
		{"pos": Vector2(1908, 1173), "color": Color(0.18, 0.58, 0.35), "is_taxi": false, "name": "Hatchback Hijau"}
	]
	
	for cfg in car_configs:
		var car = car_scene.instantiate()
		car.position = cfg["pos"]
		car.car_color = cfg["color"]
		car.is_taxi = cfg["is_taxi"]
		car.car_name = cfg["name"]
		get_parent().call_deferred("add_child", car)

func _build_all_colliders() -> void:
	var sb = StaticBody2D.new()
	sb.name = "WorldCollisionBody"
	sb.collision_layer = 1
	sb.collision_mask = 0
	add_child(sb)
	collision_bodies.append(sb)

	# 1. Batas Luar Dunia (World Boundaries)
	_add_box_collider(sb, Rect2(-40, -40, 2500, 40))
	_add_box_collider(sb, Rect2(-40, 1311, 2500, 40))
	_add_box_collider(sb, Rect2(-40, -40, 40, 1400))
	_add_box_collider(sb, Rect2(2420, -40, 40, 1400))

	# 2. Gedung-Gedung Utama (Otomatis Pixel-Perfect dari PNG Transparan)
	var pol_sk = 1.0 if (polisi_skala == null or polisi_skala <= 0.0) else float(polisi_skala)
	var pol_w = (polisi_lebar if (polisi_lebar != null and polisi_lebar > 0.0) else 341.0) * pol_sk
	var pol_h = (polisi_tinggi if (polisi_tinggi != null and polisi_tinggi > 0.0) else 350.0) * pol_sk
	var pol_rect = Rect2(8 + (polisi_geser_x if polisi_geser_x != null else 0.0), 955 + (polisi_geser_y if polisi_geser_y != null else 0.0), pol_w, pol_h)
	_add_bitmap_collider(sb, tex_police, pol_rect)

	var r_sk = 1.0 if (rs_skala == null or rs_skala <= 0.0) else float(rs_skala)
	var r_w = (rs_lebar if (rs_lebar != null and rs_lebar > 0.0) else 585.0) * r_sk
	var r_h = (rs_tinggi if (rs_tinggi != null and rs_tinggi > 0.0) else 300.0) * r_sk
	var rs_rect = Rect2(465 + (rs_geser_x if rs_geser_x != null else 0.0), 945 + (rs_geser_y if rs_geser_y != null else 0.0), r_w, r_h)
	_add_bitmap_collider(sb, tex_hospital, rs_rect)

	# Gedung Stasiun Kereta
	var st_sk = 1.0 if (stasiun_skala == null or stasiun_skala <= 0.0) else float(stasiun_skala)
	var st_w = (stasiun_lebar if (stasiun_lebar != null and stasiun_lebar > 0.0) else 300.0) * st_sk
	var st_h = (stasiun_tinggi if (stasiun_tinggi != null and stasiun_tinggi > 0.0) else 621.0) * st_sk
	_add_box_collider(sb, Rect2(1991 + (stasiun_geser_x if stasiun_geser_x != null else 0.0), 698 + (stasiun_geser_y if stasiun_geser_y != null else 0.0), 142 * st_sk, 245 * st_sk))

	# 2 Rumah Blok NE (Bodi rumah + pagar halaman)
	var rne_sk = 1.0 if (rumah_ne_skala == null or rumah_ne_skala <= 0.0) else float(rumah_ne_skala)
	var rne_w = (rumah_ne_lebar if (rumah_ne_lebar != null and rumah_ne_lebar > 0.0) else 132.0) * rne_sk
	var rne_h = (rumah_ne_tinggi if (rumah_ne_tinggi != null and rumah_ne_tinggi > 0.0) else 116.0) * rne_sk
	var rne_gx = (rumah_ne_geser_x if rumah_ne_geser_x != null else 0.0)
	var rne_gy = (rumah_ne_geser_y if rumah_ne_geser_y != null else 0.0)

	for n_pos in get_ne_house_positions():
		var sq_x = n_pos.x
		var sq_y = n_pos.y
		# Bodi Rumah Utama dari PNG
		_add_bitmap_collider(sb, tex_rumah_depan, Rect2(sq_x + 12 + rne_gx, sq_y + 6 + rne_gy, rne_w, rne_h))
		# Pagar Belakang
		_add_box_collider(sb, Rect2(sq_x - 4, sq_y - 8, 164, 16))
		# Pagar Samping Kiri & Kanan - box collider sederhana
		_add_box_collider(sb, Rect2(sq_x - 5, sq_y, 8, 130))
		_add_box_collider(sb, Rect2(sq_x + 155, sq_y, 8, 130))
		# Pagar Depan
		_add_box_collider(sb, Rect2(sq_x, sq_y + 130.0, 62.0, 10.0))
		_add_box_collider(sb, Rect2(sq_x + 94.0, sq_y + 130.0, 62.0, 10.0))

	var sk_kiri = (pagar_kiri_skala if (pagar_kiri_skala != null and pagar_kiri_skala > 0.0) else 1.0)
	var sk_kanan = (pagar_kanan_skala if (pagar_kanan_skala != null and pagar_kanan_skala > 0.0) else 1.0)
	var side_w = (pagar_samping_lebar if (pagar_samping_lebar != null and pagar_samping_lebar > 0.0) else 12.0)
	var side_total_h = (pagar_samping_tinggi if (pagar_samping_tinggi != null and pagar_samping_tinggi > 0.0) else 148.0)
	var n_panels = max(1, 2 if (pagar_samping_jumlah_panel == null or pagar_samping_jumlah_panel <= 0) else int(pagar_samping_jumlah_panel))
	var overlap_px = 16.0
	var panel_h = (side_total_h + (n_panels - 1) * overlap_px) / float(n_panels)
	var step_y = panel_h - overlap_px + (0.0 if pagar_samping_gap_panel == null else float(pagar_samping_gap_panel))

	var ra_sk = 1.0 if (rumah_atas_skala == null or rumah_atas_skala <= 0.0) else float(rumah_atas_skala)
	var ra_w = (rumah_atas_lebar if (rumah_atas_lebar != null and rumah_atas_lebar > 0.0) else 132.0) * ra_sk
	var ra_h = (rumah_atas_tinggi if (rumah_atas_tinggi != null and rumah_atas_tinggi > 0.0) else 116.0) * ra_sk
	var ra_gx = (rumah_atas_geser_x if rumah_atas_geser_x != null else 0.0)
	var ra_gy = (rumah_atas_geser_y if rumah_atas_geser_y != null else 0.0)

	# 3. Rumah Warga & Pagar Halaman (11 Rumah Atas)
	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		var sq_y = 36.0
		# Bodi Rumah Utama dari PNG (Rumah MC Detektif Benedict i==6 menggunakan tex_rumah_mc dengan atap merah)
		var h_tex = tex_rumah_mc if i == 6 else tex_rumah_depan
		_add_bitmap_collider(sb, h_tex, Rect2(sq_x + 12 + ra_gx, sq_y + 6 + ra_gy, ra_w, ra_h))
		# Pagar Belakang
		_add_box_collider(sb, Rect2(sq_x - 4, sq_y - 8, 164, 16))
		# Pagar Samping Kiri & Kanan - box collider sederhana (lebih stabil)
		_add_box_collider(sb, Rect2(sq_x - 5 + (pagar_samping_kiri_geser_x if pagar_samping_kiri_geser_x != null else 0.0), sq_y, 8, 130))
		_add_box_collider(sb, Rect2(sq_x + 155 + (pagar_samping_kanan_geser_x if pagar_samping_kanan_geser_x != null else 0.0), sq_y, 8, 130))
		# Pagar Depan Kiri & Kanan - box collider sederhana
		var f_left_rect = Rect2(sq_x + (pagar_kiri_geser_x if pagar_kiri_geser_x != null else 0.0), sq_y + 130.0 + (pagar_kiri_geser_y if pagar_kiri_geser_y != null else 0.0), (pagar_kiri_lebar if pagar_kiri_lebar != null else 62.0), 10.0)
		_add_box_collider(sb, f_left_rect)
		var f_right_rect = Rect2(sq_x + 94.0 + (pagar_kanan_geser_x if pagar_kanan_geser_x != null else 0.0), sq_y + 130.0 + (pagar_kanan_geser_y if pagar_kanan_geser_y != null else 0.0), (pagar_kanan_lebar if pagar_kanan_lebar != null else 62.0), 10.0)
		_add_box_collider(sb, f_right_rect)

	var rse_sk = 1.0 if (rumah_se_skala == null or rumah_se_skala <= 0.0) else float(rumah_se_skala)
	var rse_w = (rumah_se_lebar if (rumah_se_lebar != null and rumah_se_lebar > 0.0) else 132.0) * rse_sk
	var rse_h = (rumah_se_tinggi if (rumah_se_tinggi != null and rumah_se_tinggi > 0.0) else 116.0) * rse_sk
	var rse_gx = (rumah_se_geser_x if rumah_se_geser_x != null else 0.0)
	var rse_gy = (rumah_se_geser_y if rumah_se_geser_y != null else 0.0)

	# 3 Rumah Tenggara
	for hy in [705.0, 880.0, 1055.0]:
		var sq_x = 1636.0
		var sq_y = hy
		# Bodi Rumah Utama dari PNG
		_add_bitmap_collider(sb, tex_rumah_depan, Rect2(sq_x + 12 + rse_gx, sq_y + 6 + rse_gy, rse_w, rse_h))
		# Pagar Belakang
		_add_box_collider(sb, Rect2(sq_x - 4, sq_y - 8, 164, 16))
		# Pagar Samping Kiri & Kanan - box collider sederhana
		_add_box_collider(sb, Rect2(sq_x - 5, sq_y, 8, 130))
		_add_box_collider(sb, Rect2(sq_x + 155, sq_y, 8, 130))
		# Pagar Depan
		_add_box_collider(sb, Rect2(sq_x, sq_y + 130.0, 62.0, 10.0))
		_add_box_collider(sb, Rect2(sq_x + 94.0, sq_y + 130.0, 62.0, 10.0))

	# 4. Pagar Kantor Polisi (Opsional dari Inspector)
	if pagar_polisi_tampilkan:
		var pp_sk = 1.0 if (pagar_polisi_skala == null or pagar_polisi_skala <= 0.0) else float(pagar_polisi_skala)
		var pp_w = (pagar_polisi_lebar if (pagar_polisi_lebar != null and pagar_polisi_lebar > 0.0) else 290.0) * pp_sk
		var pp_x = 8.0 + (polisi_geser_x if polisi_geser_x != null else 0.0) + (pagar_polisi_geser_x if pagar_polisi_geser_x != null else 0.0)
		var pp_y = 955.0 + (polisi_geser_y if polisi_geser_y != null else 0.0) + (pagar_polisi_geser_y if pagar_polisi_geser_y != null else 0.0)
		_add_bitmap_collider(sb, tex_pagar, Rect2(pp_x, pp_y, pp_w, 26.0 * pp_sk))

	# 5. Pagar Rumah Sakit (Opsional dari Inspector)
	if pagar_rs_tampilkan:
		var prs_sk = 1.0 if (pagar_rs_skala == null or pagar_rs_skala <= 0.0) else float(pagar_rs_skala)
		var prs_w = (pagar_rs_lebar if (pagar_rs_lebar != null and pagar_rs_lebar > 0.0) else 585.0) * prs_sk
		var prs_x = 465.0 + (rs_geser_x if rs_geser_x != null else 0.0) + (pagar_rs_geser_x if pagar_rs_geser_x != null else 0.0)
		var prs_y = 945.0 + (rs_geser_y if rs_geser_y != null else 0.0) + (pagar_rs_geser_y if pagar_rs_geser_y != null else 0.0)
		_add_bitmap_collider(sb, tex_pagar, Rect2(prs_x, prs_y, prs_w, 26.0 * prs_sk))

	# 6. Pagar Pembatas Ujung Timur Stasiun Kereta
	if pagar_kereta_tampilkan:
		var pk_sk = 1.0 if (pagar_kereta_skala == null or pagar_kereta_skala <= 0.0) else float(pagar_kereta_skala)
		var pk_x = 2280.0 + 140.0 + (pagar_kereta_geser_x if pagar_kereta_geser_x != null else 0.0)
		var pk_y = 690.0 + (pagar_kereta_geser_y if pagar_kereta_geser_y != null else 0.0)
		var pk_h = (pagar_kereta_tinggi if (pagar_kereta_tinggi != null and pagar_kereta_tinggi > 0.0) else 621.0) * pk_sk
		_add_box_collider(sb, Rect2(pk_x - 4, pk_y, 8, pk_h))

	# 7. Gedung-Gedung di Blok NW (Box Colliders Kokoh per Kolom)
	if gedung_nw_tampilkan:
		for col_rect in get_nw_gedung_columns():
			_add_box_collider(sb, col_rect)

	# 7b. Gedung Benjolan Persegi NW
	if gedung_benjolan_tampilkan:
		_add_box_collider(sb, get_benjolan_gedung_rect())

	# 7c. Kolam Renang NW (Hanya air kolam yang memiliki kolisi solid agar pemain bisa jalan di dek)
	if gedung_nw_kolam_tampilkan:
		_add_box_collider(sb, get_nw_kolam_water_rect())

	# 7d. Kompleks Metropolitan World Trade Center
	if wtc_tampilkan:
		# Gedung Finansial Barisan Utara (5 Gedung)
		for b in get_wtc_north_towers():
			_add_box_collider(sb, Rect2(b.position.x, b.position.y + b.size.y * 0.45, b.size.x, b.size.y * 0.55))
		# Menara Kembar WTC (1 WTC & 2 WTC)
		for b in get_wtc_twin_towers():
			_add_box_collider(sb, Rect2(b.position.x, b.position.y + b.size.y * 0.45, b.size.x, b.size.y * 0.55))
		# Gedung Sayap Selatan (3 WTC & 4 WTC)
		for b in get_wtc_south_flank_towers():
			_add_box_collider(sb, Rect2(b.position.x, b.position.y + b.size.y * 0.45, b.size.x, b.size.y * 0.55))
		# Kolam Refleksi Memorial WTC (Solid agar tidak bisa masuk ke air)
		if wtc_pool_tampilkan:
			_add_box_collider(sb, get_wtc_memorial_pool_rect())

	# 8. Gedung di Samping Rumah Sakit
	if gedung_rs_tampilkan:
		for b_rect in get_rs_gedung_rects():
			_add_box_collider(sb, b_rect)

func _add_bitmap_collider(body: StaticBody2D, tex: Texture2D, target_rect: Rect2, alpha_threshold: float = 0.25, epsilon: float = 5.0) -> void:
	if not is_instance_valid(tex):
		return
	var img: Image = tex.get_image()
	if not img:
		return
	var src_w: int = img.get_width()
	var src_h: int = img.get_height()
	if src_w <= 0 or src_h <= 0:
		return

	var scale_factor: float = min(target_rect.size.x / float(src_w), target_rect.size.y / float(src_h))
	var draw_size := Vector2(src_w, src_h) * scale_factor
	var draw_pos := target_rect.position + (target_rect.size - draw_size) * 0.5

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img, alpha_threshold)
	var polys: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2i(0, 0, src_w, src_h), epsilon)

	for poly in polys:
		if poly.size() < 3:
			continue
		var scaled_poly := PackedVector2Array()
		scaled_poly.resize(poly.size())
		for pi in range(poly.size()):
			scaled_poly[pi] = draw_pos + poly[pi] * scale_factor
		var col := CollisionPolygon2D.new()
		col.polygon = scaled_poly
		body.add_child(col)

func _add_flipped_bitmap_collider(body: StaticBody2D, tex: Texture2D, target_rect: Rect2, flip_h: bool = false, flip_v: bool = false, alpha_threshold: float = 0.25, epsilon: float = 5.0) -> void:
	if not is_instance_valid(tex):
		return
	var img: Image = tex.get_image()
	if not img:
		return
	if flip_h or flip_v:
		img = img.duplicate()
		if flip_h:
			img.flip_x()
		if flip_v:
			img.flip_y()
	var src_w: int = img.get_width()
	var src_h: int = img.get_height()
	if src_w <= 0 or src_h <= 0:
		return

	var scale_factor: float = min(target_rect.size.x / float(src_w), target_rect.size.y / float(src_h))
	var draw_size := Vector2(src_w, src_h) * scale_factor
	var draw_pos := target_rect.position + (target_rect.size - draw_size) * 0.5

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img, alpha_threshold)
	var polys: Array[PackedVector2Array] = bitmap.opaque_to_polygons(Rect2i(0, 0, src_w, src_h), epsilon)

	for poly in polys:
		if poly.size() < 3:
			continue
		var scaled_poly := PackedVector2Array()
		scaled_poly.resize(poly.size())
		for pi in range(poly.size()):
			scaled_poly[pi] = draw_pos + poly[pi] * scale_factor
		var col := CollisionPolygon2D.new()
		col.polygon = scaled_poly
		body.add_child(col)

func _add_side_fence_bitmap_collider(body: StaticBody2D, rect: Rect2, flip_h: bool = false) -> void:
	if not is_instance_valid(tex_pagar_samping):
		return
	var img: Image = tex_pagar_samping.get_image()
	if not img:
		return
	var region := Rect2i(19, 24, 31, 329)
	var cropped := img.get_region(region)
	if flip_h:
		cropped.flip_x()
	var src_w = cropped.get_width()
	var src_h = cropped.get_height()
	if src_w <= 0 or src_h <= 0:
		return
	var scale_x = rect.size.x / float(src_w)
	var scale_y = rect.size.y / float(src_h)

	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(cropped, 0.25)
	var polys = bitmap.opaque_to_polygons(Rect2i(0, 0, src_w, src_h), 2.0)
	for poly in polys:
		if poly.size() < 3:
			continue
		var scaled_poly := PackedVector2Array()
		scaled_poly.resize(poly.size())
		for pi in range(poly.size()):
			scaled_poly[pi] = rect.position + Vector2(poly[pi].x * scale_x, poly[pi].y * scale_y)
		var col := CollisionPolygon2D.new()
		col.polygon = scaled_poly
		body.add_child(col)

func _add_box_collider(body: StaticBody2D, rect: Rect2) -> void:
	var shape = CollisionShape2D.new()
	var box = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	shape.position = rect.position + rect.size * 0.5
	body.add_child(shape)

func _load_textures() -> void:
	tex_hospital = load("res://Environment/Bangunan/Hospital.png")
	tex_police = load("res://Environment/Bangunan/police.png")
	tex_gedung = load("res://Environment/Bangunan/gedung.png")
	tex_rumah_mc = load("res://Environment/Bangunan/rumahMC.png")
	tex_rumah_depan = load("res://Environment/Bangunan/rumahTampakDepan.png")
	tex_rumah_belakang = load("res://Environment/Bangunan/rumahTampakBelakang.png")
	tex_rumah_samping = load("res://Environment/Bangunan/rumahTampakSamping.png")
	tex_pagar = load("res://Environment/Bangunan/pagar.png")
	tex_pagar_samping = load("res://Environment/Bangunan/pagar samping.png")
	tex_pintu_pagar = load("res://Environment/Bangunan/pintuPagar.png")
	tex_telepon = load("res://Environment/Bangunan/stasiun telepon.png")

	tex_bed = load("res://Environment/kamar/bed.png")
	tex_karpet = load("res://Environment/kamar/karpet.png")
	tex_laci = load("res://Environment/kamar/laci.png")
	tex_lemari = load("res://Environment/kamar/lemari.png")

	tex_baskom = load("res://Environment/interactable assets/baskom cetak photo.png")
	tex_surat = load("res://Environment/interactable assets/surat.png")

func _draw_texture_fit(tex: Texture2D, target_rect: Rect2) -> void:
	if not is_instance_valid(tex):
		return
	var src_size = tex.get_size()
	if src_size.x <= 0 or src_size.y <= 0:
		return
	var scale_factor = min(target_rect.size.x / src_size.x, target_rect.size.y / src_size.y)
	var draw_size = src_size * scale_factor
	var draw_pos = target_rect.position + (target_rect.size - draw_size) * 0.5
	draw_texture_rect(tex, Rect2(draw_pos, draw_size), false)

func _draw_side_fence(rect: Rect2, flip_h: bool = false) -> void:
	if not is_instance_valid(tex_pagar_samping):
		return
	var src_region = Rect2(19, 24, 31, 329)
	if not flip_h:
		draw_texture_rect_region(tex_pagar_samping, rect, src_region)
	else:
		draw_set_transform(Vector2(rect.position.x + rect.size.x, rect.position.y), 0.0, Vector2(-1.0, 1.0))
		draw_texture_rect_region(tex_pagar_samping, Rect2(0, 0, rect.size.x, rect.size.y), src_region)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_phone_booth(rect: Rect2) -> void:
	if not is_instance_valid(tex_telepon):
		return
	var src_region = Rect2(359, 138, 286, 606)
	draw_texture_rect_region(tex_telepon, rect, src_region)

func _draw_texture_flipped(tex: Texture2D, rect: Rect2, flip_h: bool = false, flip_v: bool = false) -> void:
	if not is_instance_valid(tex):
		return
	if not flip_h and not flip_v:
		draw_texture_rect(tex, rect, false)
		return
	var scale_vec = Vector2(-1.0 if flip_h else 1.0, -1.0 if flip_v else 1.0)
	var origin_x = rect.position.x + (rect.size.x if flip_h else 0.0)
	var origin_y = rect.position.y + (rect.size.y if flip_v else 0.0)
	draw_set_transform(Vector2(origin_x, origin_y), 0.0, scale_vec)
	draw_texture_rect(tex, Rect2(0, 0, rect.size.x, rect.size.y), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _setup_navigation_region() -> void:
	nav_region = NavigationRegion2D.new()
	nav_region.name = "NavigationRegion2D"
	var nav_poly = NavigationPolygon.new()

	var outer_boundary = PackedVector2Array([
		Vector2(0, 192),
		Vector2(2420, 192),
		Vector2(2420, 1311),
		Vector2(0, 1311)
	])
	nav_poly.add_outline(outer_boundary)

	# Gedung-gedung Blok NW (outlines per kolom)
	if gedung_nw_tampilkan:
		for col_rect in get_nw_gedung_columns():
			nav_poly.add_outline(PackedVector2Array([
				col_rect.position,
				Vector2(col_rect.end.x, col_rect.position.y),
				col_rect.end,
				Vector2(col_rect.position.x, col_rect.end.y)
			]))

	# Gedung Benjolan Persegi NW
	if gedung_benjolan_tampilkan:
		var bg_rect := get_benjolan_gedung_rect()
		nav_poly.add_outline(PackedVector2Array([
			bg_rect.position,
			Vector2(bg_rect.end.x, bg_rect.position.y),
			bg_rect.end,
			Vector2(bg_rect.position.x, bg_rect.end.y)
		]))

	# Kolam Renang NW (Lubang Navmesh di Air agar karakter jalan di dek)
	if gedung_nw_kolam_tampilkan:
		var kw_rect := get_nw_kolam_water_rect()
		nav_poly.add_outline(PackedVector2Array([
			kw_rect.position,
			Vector2(kw_rect.end.x, kw_rect.position.y),
			kw_rect.end,
			Vector2(kw_rect.position.x, kw_rect.end.y)
		]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(10, 961), Vector2(347, 961), Vector2(347, 1301), Vector2(10, 1301)
	]))
	
	# Kompleks Metropolitan World Trade Center (North Financial Skyscraper Row)
	if wtc_tampilkan:
		for b in get_wtc_north_towers():
			var base_r = Rect2(b.position.x, b.position.y + b.size.y * 0.45, b.size.x, b.size.y * 0.55)
			nav_poly.add_outline(PackedVector2Array([
				base_r.position, Vector2(base_r.end.x, base_r.position.y),
				base_r.end, Vector2(base_r.position.x, base_r.end.y)
			]))

	# Dua Rumah Blok NE
	for n_pos in get_ne_house_positions():
		nav_poly.add_outline(PackedVector2Array([
			Vector2(n_pos.x, n_pos.y), Vector2(n_pos.x + 156, n_pos.y),
			Vector2(n_pos.x + 156, n_pos.y + 156), Vector2(n_pos.x, n_pos.y + 156)
		]))
	
	nav_poly.add_outline(PackedVector2Array([
		Vector2(649, 700), Vector2(1040, 700), Vector2(1040, 1235),
		Vector2(475, 1235), Vector2(475, 955), Vector2(649, 955)
	]))
	
	# Kompleks Metropolitan World Trade Center (Twin Towers, Flanking Towers, Memorial Pool)
	if wtc_tampilkan:
		for b in get_wtc_twin_towers():
			var base_r = Rect2(b.position.x, b.position.y + b.size.y * 0.45, b.size.x, b.size.y * 0.55)
			nav_poly.add_outline(PackedVector2Array([
				base_r.position, Vector2(base_r.end.x, base_r.position.y),
				base_r.end, Vector2(base_r.position.x, base_r.end.y)
			]))
		for b in get_wtc_south_flank_towers():
			var base_r = Rect2(b.position.x, b.position.y + b.size.y * 0.45, b.size.x, b.size.y * 0.55)
			nav_poly.add_outline(PackedVector2Array([
				base_r.position, Vector2(base_r.end.x, base_r.position.y),
				base_r.end, Vector2(base_r.position.x, base_r.end.y)
			]))
		if wtc_pool_tampilkan:
			var pool_r = get_wtc_memorial_pool_rect()
			nav_poly.add_outline(PackedVector2Array([
				pool_r.position, Vector2(pool_r.end.x, pool_r.position.y),
				pool_r.end, Vector2(pool_r.position.x, pool_r.end.y)
			]))

	# Tiga Rumah Warga Tenggara
	for hy in [705.0, 880.0, 1055.0]:
		nav_poly.add_outline(PackedVector2Array([
			Vector2(1636, hy), Vector2(1792, hy), Vector2(1792, hy + 156), Vector2(1636, hy + 156)
		]))

	# Navigation baking - tambahkan ke scene tree dulu sebelum baking
	nav_region.navigation_polygon = nav_poly
	add_child(nav_region)
	# Baking async setelah node masuk scene tree
	call_deferred("_bake_nav_region", nav_region, nav_poly)

func _bake_nav_region(nav_region: NavigationRegion2D, nav_poly: NavigationPolygon) -> void:
	if not is_instance_valid(nav_region):
		return
	var source_data = NavigationMeshSourceGeometryData2D.new()
	NavigationServer2D.parse_source_geometry_data(nav_poly, source_data, self)
	NavigationServer2D.bake_from_source_geometry_data(nav_poly, source_data, func():
		if is_instance_valid(nav_region):
			nav_region.navigation_polygon = nav_poly
	)

func _draw() -> void:
	if tex_rumah_mc == null or tex_rumah_depan == null:
		_load_textures()

	draw_rect(Rect2(-200, -200, 2800, 1800), COLOR_VOID, true)

	draw_rect(Rect2(0, 0, 2160, 1311), COLOR_SIDEWALK, true)

	for gx in range(40, 2160, 40):
		draw_line(Vector2(gx, 0), Vector2(gx, 1311), Color(0, 0, 0, 0.08), 1.0)
	for gy in range(40, 1311, 40):
		draw_line(Vector2(0, gy), Vector2(2160, gy), Color(0, 0, 0, 0.08), 1.0)

	for i in range(11):
		var sq_x = (13.0 + i * 62.0) * 3.0
		var g_key = "top_%d" % i
		# Rumah MC Detektif Benedict berada pada urutan ke-6 (i == 6) dengan atap merah (tex_rumah_mc)
		var house_tex = tex_rumah_mc if i == 6 else tex_rumah_depan
		_draw_civilian_fenced_house(Vector2(sq_x, 36), house_tex, g_key)

	# ── Ruang Gedung Barat Laut (North-West Complex) ─────────────────────────
	var l_pts = PackedVector2Array([
		Vector2(0, 324), Vector2(516, 324), Vector2(516, 786),
		Vector2(192, 786), Vector2(192, 933), Vector2(0, 933)
	])
	if gedung_nw_rumput_tampilkan:
		# Lapisan Rumput Hijau Segar
		draw_colored_polygon(l_pts, Color(0.33, 0.52, 0.22))
		# Tekstur Rumput (Bercak rumput halus)
		for gx in range(30, 500, 52):
			for gy in range(340, 770, 52):
				var offset_hash: float = float((gx * 73 + gy * 37) % 17) - 8.0
				draw_line(Vector2(gx + offset_hash, gy), Vector2(gx + offset_hash + 4, gy - 6), Color(0.27, 0.44, 0.18, 0.6), 1.5)
				draw_line(Vector2(gx + offset_hash + 4, gy - 6), Vector2(gx + offset_hash + 8, gy), Color(0.27, 0.44, 0.18, 0.6), 1.5)
		for gx in range(20, 180, 40):
			for gy in range(790, 920, 40):
				draw_line(Vector2(gx, gy), Vector2(gx + 4, gy - 5), Color(0.27, 0.44, 0.18, 0.6), 1.5)

		# Jalur Setapak Batu (Stone Walkway Network) terintegrasi
		var kw_rect := get_nw_kolam_water_rect()
		var p_color := Color(0.82, 0.80, 0.74)
		var p_border := Color(0.68, 0.66, 0.60)
		
		# 1. Promenade / Trotoar Utama di Depan Pintu Gedung Baris Depan
		draw_rect(Rect2(40, 668, 436, 16), p_color, true)
		draw_rect(Rect2(40, 668, 436, 16), p_border, false, 1.0)
		
		# 2. Akses ke Gerbang Timur (x=516, y=540) lewat lorong timur
		draw_rect(Rect2(476, 532, 40, 16), p_color, true)
		draw_rect(Rect2(476, 532, 40, 16), p_border, false, 1.0)
		draw_rect(Rect2(476, 532, 16, 140), p_color, true)
		draw_rect(Rect2(476, 532, 16, 140), p_border, false, 1.0)
		
		# 3. Akses ke Gerbang Selatan (x=350, y=786) di samping kolam
		draw_rect(Rect2(344, 768, 16, 18), p_color, true)
		draw_rect(Rect2(344, 768, 16, 18), p_border, false, 1.0)
		
		# 4. Akses ke Gedung Benjolan Persegi (x=54, y=742)
		draw_rect(Rect2(54, 684, 16, 60), p_color, true)
		draw_rect(Rect2(54, 684, 16, 60), p_border, false, 1.0)
	else:
		draw_colored_polygon(l_pts, COLOR_ROOM_STONE_A)
		_draw_tile_pattern(Rect2(0, 324, 516, 462), COLOR_PLAZA_TILE_LINE)
		_draw_tile_pattern(Rect2(0, 786, 192, 147), COLOR_PLAZA_TILE_LINE)


	# Kompleks Metropolitan World Trade Center — Lantai Dasar Plaza Utara & Selatan
	if wtc_tampilkan:
		# Plaza Finansial Utara (x=639..1536, y=324..549)
		draw_rect(Rect2(639, 324, 897, 225), Color(0.26, 0.28, 0.31), true)
		_draw_tile_pattern(Rect2(639, 324, 897, 225), Color(0.20, 0.22, 0.25, 0.6))
		
		# Distrik World Trade Center Selatan (x=1050..1536, y=690..1245)
		draw_rect(Rect2(1050, 690, 486, 555), Color(0.26, 0.28, 0.31), true)
		_draw_tile_pattern(Rect2(1050, 690, 486, 555), Color(0.20, 0.22, 0.25, 0.6))
		# Koridor / Esplanade Marmer Tengah WTC
		draw_rect(Rect2(1165, 690, 206, 555), Color(0.31, 0.33, 0.37), true)
		draw_line(Vector2(1165, 690), Vector2(1165, 1245), Color(0.42, 0.45, 0.50, 0.6), 2.0)
		draw_line(Vector2(1371, 690), Vector2(1371, 1245), Color(0.42, 0.45, 0.50, 0.6), 2.0)

	# Kompleks Rumah Sakit Bawah (Taman & Gedung RS)
	var bot_complex_pts = PackedVector2Array([
		Vector2(639, 690), Vector2(1050, 690), Vector2(1050, 1245),
		Vector2(465, 1245), Vector2(465, 945), Vector2(639, 945)
	])
	draw_colored_polygon(bot_complex_pts, COLOR_ROOM_STONE_B)
	_draw_tile_pattern(Rect2(639, 690, 411, 255), COLOR_PLAZA_TILE_LINE)
	_draw_courtyard_garden(Vector2(780, 830), 40.0)
	
	# 🏠🏠 Dua Rumah Berpekarangan di Blok NE (1626,324)→(2016,549)
	var ne_positions = get_ne_house_positions()
	_draw_civilian_fenced_house(ne_positions[0], tex_rumah_depan, "ne_0", "ne")
	_draw_civilian_fenced_house(ne_positions[1], tex_rumah_depan, "ne_1", "ne")

	# Presisi Kantor Polisi
	_draw_room_pavement(Rect2(0, 951, 357, 360), COLOR_ROOM_STONE_B)

	# ── Jaringan Jalan Raya Kota (Digambar Di Atas Lantai & Tanah) ────────────
	_draw_city_road_network()

	# ── Stasiun Telepon Umum Kota ─────────────────────────────────────────────
	var phone_spots = [
		Vector2(480, 225),
		Vector2(991, 545),
		Vector2(1980, 225),
		Vector2(1460, 1195)
	]
	var tw = telepon_lebar * (1.0 if (telepon_skala == null or telepon_skala <= 0.0) else float(telepon_skala))
	var th = telepon_tinggi * (1.0 if (telepon_skala == null or telepon_skala <= 0.0) else float(telepon_skala))
	for p_pos in phone_spots:
		_draw_phone_booth(Rect2(p_pos.x, p_pos.y, tw, th))

	# 🏢 1. Gedung-Gedung Blok NW (North-West Complex) — proporsi asli, skala seragam
	if gedung_nw_tampilkan and is_instance_valid(tex_gedung):
		var nw_rects := get_nw_gedung_rects()
		for idx in range(nw_rects.size()):
			var b_rect: Rect2 = nw_rects[idx]
			var r: int = int(floor(float(idx) / float(max(1, gedung_nw_kolom))))
			# Bayangan jatuh (Drop Shadow) di bawah tumpukan gedung
			if gedung_nw_depth_shadow:
				draw_rect(Rect2(b_rect.position.x - 3, b_rect.position.y - 8, b_rect.size.x + 6, 12), Color(0, 0, 0, 0.22), true)
				draw_rect(Rect2(b_rect.position.x - 4, b_rect.end.y - 4, b_rect.size.x + 8, 8), Color(0, 0, 0, 0.22), true)
			# Atmospheric Depth Tinting
			var total_rows: int = max(1, gedung_nw_baris)
			var tint := Color.WHITE
			if gedung_nw_depth_tint:
				if r == 0 and total_rows > 1:
					tint = Color(0.82, 0.85, 0.92, 1.0)
				elif r < total_rows - 1:
					tint = Color(0.92, 0.94, 0.97, 1.0)
			draw_texture_rect_region(tex_gedung, b_rect, GEDUNG_SRC_RECT, tint)
			if gedung_nw_rooftop_props:
				_draw_rooftop_props_to(self, b_rect, idx)

	# 🏢 1b. Gedung Benjolan Persegi NW (Menempati area benjolan x=0..192, y=786..933)
	if gedung_benjolan_tampilkan and is_instance_valid(tex_gedung):
		var bg_rect := get_benjolan_gedung_rect()
		if gedung_nw_depth_shadow:
			draw_rect(Rect2(bg_rect.position.x - 4, bg_rect.end.y - 4, bg_rect.size.x + 8, 8), Color(0, 0, 0, 0.25), true)
		draw_texture_rect_region(tex_gedung, bg_rect, GEDUNG_SRC_RECT, Color.WHITE)
		if gedung_nw_rooftop_props:
			_draw_rooftop_props_to(self, bg_rect, 99)

	# 🏊 Kolam Renang Mewah NW (Courtyard Pool)
	if gedung_nw_kolam_tampilkan:
		_draw_swimming_pool(get_nw_kolam_water_rect())

	# 🏥 2. Gedung samping RS (bot complex) (639,690)→(1050,1245) - Skala Seragam
	if gedung_rs_tampilkan and is_instance_valid(tex_gedung):
		var rs_rects := get_rs_gedung_rects()
		for idx in range(rs_rects.size()):
			var b_rect: Rect2 = rs_rects[idx]
			if gedung_nw_depth_shadow:
				draw_rect(Rect2(b_rect.position.x - 3, b_rect.position.y - 6, b_rect.size.x + 6, 10), Color(0, 0, 0, 0.22), true)
				draw_rect(Rect2(b_rect.position.x - 4, b_rect.end.y - 4, b_rect.size.x + 8, 8), Color(0, 0, 0, 0.22), true)
			draw_texture_rect_region(tex_gedung, b_rect, GEDUNG_SRC_RECT, Color.WHITE)
			if gedung_nw_rooftop_props:
				_draw_rooftop_props_to(self, b_rect, 80 + idx)

	# 🏛️ 3. Kompleks Metropolitan World Trade Center (Twin Towers, Reflecting Pool, North Skyscraper Row)
	_draw_wtc_complex()

	var pol_sk = 1.0 if (polisi_skala == null or polisi_skala <= 0.0) else float(polisi_skala)
	var pol_w = (polisi_lebar if (polisi_lebar != null and polisi_lebar > 0.0) else 341.0) * pol_sk
	var pol_h = (polisi_tinggi if (polisi_tinggi != null and polisi_tinggi > 0.0) else 350.0) * pol_sk
	_draw_texture_fit(tex_police, Rect2(8 + polisi_geser_x, 955 + polisi_geser_y, pol_w, pol_h))
	if pagar_polisi_tampilkan:
		var pp_sk = 1.0 if (pagar_polisi_skala == null or pagar_polisi_skala <= 0.0) else float(pagar_polisi_skala)
		var pp_w = (pagar_polisi_lebar if (pagar_polisi_lebar != null and pagar_polisi_lebar > 0.0) else 290.0) * pp_sk
		var pp_x = 8.0 + (polisi_geser_x if polisi_geser_x != null else 0.0) + (pagar_polisi_geser_x if pagar_polisi_geser_x != null else 0.0)
		var pp_y = 955.0 + (polisi_geser_y if polisi_geser_y != null else 0.0) + (pagar_polisi_geser_y if pagar_polisi_geser_y != null else 0.0)
		_draw_texture_fit(tex_pagar, Rect2(pp_x, pp_y, pp_w, 26.0 * pp_sk))

	# Gedung Utama Rumah Sakit (Dapat diatur lewat Inspector)
	var r_sk = 1.0 if (rs_skala == null or rs_skala <= 0.0) else float(rs_skala)
	var r_w = (rs_lebar if (rs_lebar != null and rs_lebar > 0.0) else 585.0) * r_sk
	var r_h = (rs_tinggi if (rs_tinggi != null and rs_tinggi > 0.0) else 300.0) * r_sk
	_draw_hospital_main_building(Rect2(465 + rs_geser_x, 945 + rs_geser_y, r_w, r_h))
	if pagar_rs_tampilkan:
		var prs_sk = 1.0 if (pagar_rs_skala == null or pagar_rs_skala <= 0.0) else float(pagar_rs_skala)
		var prs_w = (pagar_rs_lebar if (pagar_rs_lebar != null and pagar_rs_lebar > 0.0) else 585.0) * prs_sk
		var prs_x = 465.0 + (rs_geser_x if rs_geser_x != null else 0.0) + (pagar_rs_geser_x if pagar_rs_geser_x != null else 0.0)
		var prs_y = 945.0 + (rs_geser_y if rs_geser_y != null else 0.0) + (pagar_rs_geser_y if pagar_rs_geser_y != null else 0.0)
		_draw_texture_fit(tex_pagar, Rect2(prs_x, prs_y, prs_w, 26.0 * prs_sk))

	# ── Area Tenggara: Tiga Rumah Warga, Gang Kecil, dan Stasiun Kereta ───────
	# 1. Tiga Rumah Warga Seberang Stasiun (Lengkap rumput & pagar sama persis seperti rumah atas)
	_draw_civilian_fenced_house(Vector2(1636, 705), tex_rumah_depan, "se_0", true)
	_draw_civilian_fenced_house(Vector2(1636, 880), tex_rumah_depan, "se_1", true)
	_draw_civilian_fenced_house(Vector2(1636, 1055), tex_rumah_depan, "se_2", true)

	# 2. Gang Kecil Penghubung Jalan Tengah & Jalan Selatan
	draw_rect(Rect2(1792, 690, 68, 621), COLOR_SIDEWALK, true)
	_draw_tile_pattern(Rect2(1792, 690, 68, 621), COLOR_PLAZA_TILE_LINE)

	# 3. Jalur Rel Kereta Api (Membentang vertikal di antara Peron 1 dan Peron 2: x=2160..2280)
	draw_rect(Rect2(2160, 0, 120, 1311), COLOR_TRACK_BALLAST, true)
	for ty in range(12, 1311, 16):
		draw_line(Vector2(2168, ty), Vector2(2272, ty), COLOR_TRACK_TIE, 3.5)
	draw_line(Vector2(2185, 0), Vector2(2185, 1311), COLOR_TRACK_RAIL, 4.5)
	draw_line(Vector2(2255, 0), Vector2(2255, 1311), COLOR_TRACK_RAIL, 4.5)

	# 4. Kompleks Stasiun Kereta Api Timur (Parkiran + Peron 1 + Penyeberangan Rel + Peron 2)
	_draw_train_station(Rect2(1860, 690, 300, 621))

	draw_line(Vector2(0, 324), Vector2(516, 324), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 324), Vector2(516, 510), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 570), Vector2(516, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(516, 786), Vector2(380, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(320, 786), Vector2(192, 786), COLOR_WALL_LINE, WT)
	draw_line(Vector2(192, 786), Vector2(192, 933), COLOR_WALL_LINE, WT)
	draw_line(Vector2(192, 933), Vector2(0, 933), COLOR_WALL_LINE, WT)

	draw_line(Vector2(0, 951), Vector2(357, 951), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 951), Vector2(357, 1080), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 1150), Vector2(357, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(357, 1311), Vector2(0, 1311), COLOR_WALL_LINE, WT)

	draw_line(Vector2(639, 690), Vector2(1050, 690), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 690), Vector2(1050, 900), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 960), Vector2(1050, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1050, 1245), Vector2(465, 1245), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 1245), Vector2(465, 945), COLOR_WALL_LINE, WT)
	draw_line(Vector2(465, 945), Vector2(639, 945), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 945), Vector2(639, 810), COLOR_WALL_LINE, WT)
	draw_line(Vector2(639, 750), Vector2(639, 690), COLOR_WALL_LINE, WT)

	# Dinding Tiga Rumah Warga Tenggara
	for hy in [705.0, 880.0, 1055.0]:
		draw_line(Vector2(1636, hy), Vector2(1792, hy), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1636, hy), Vector2(1636, hy + 156), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1792, hy), Vector2(1792, hy + 156), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1636, hy + 156), Vector2(1696, hy + 156), COLOR_WALL_LINE, WT)
		draw_line(Vector2(1732, hy + 156), Vector2(1792, hy + 156), COLOR_WALL_LINE, WT)

	# Batas Gang & Stasiun Kereta
	draw_line(Vector2(1792, 690), Vector2(1792, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1860, 690), Vector2(1860, 1311), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1860, 690), Vector2(2160, 690), COLOR_WALL_LINE, WT)
	draw_line(Vector2(1860, 1311), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	draw_line(Vector2(2160, 0), Vector2(2160, 1311), COLOR_WALL_LINE, WT)

	_draw_poi_badge(Vector2(1200, 210), "Rumah Detektif Benedict", Color(0.95, 0.35, 0.30))
	_draw_poi_badge(Vector2(350, 258),  "Kantor Polisi",  Color(0.25, 0.50, 0.85))
	_draw_poi_badge(Vector2(2020, 960), "Stasiun Kereta", Color(0.95, 0.70, 0.20))
	_draw_poi_badge(Vector2(1270, 710), "World Trade Center", Color(0.20, 0.48, 0.78))
	_draw_poi_badge(Vector2(750, 1095), "Rumah Sakit",    Color(0.85, 0.25, 0.25))
	_draw_poi_badge(Vector2(180, 1050), "Brankas Ibu",    Color(0.80, 0.50, 0.90))

func _draw_civilian_fenced_house(pos: Vector2, house_tex: Texture2D = null, gate_key: String = "", house_type: Variant = "atas") -> void:
	var sq_x = pos.x
	var sq_y = pos.y
	var r_rect = Rect2(sq_x, sq_y, 156, 156)

	draw_rect(r_rect, Color(0.35, 0.52, 0.22), true)
	draw_rect(Rect2(sq_x + 64, sq_y + 94, 28, 62), Color(0.70, 0.68, 0.62), true)

	var h_tex = tex_rumah_depan if house_tex == null else house_tex
	var h_sk: float = 1.0
	var h_w: float = 132.0
	var h_h: float = 116.0
	var h_gx: float = 0.0
	var h_gy: float = 0.0

	if str(house_type) == "ne":
		h_sk = 1.0 if (rumah_ne_skala == null or rumah_ne_skala <= 0.0) else float(rumah_ne_skala)
		h_w = (rumah_ne_lebar if (rumah_ne_lebar != null and rumah_ne_lebar > 0.0) else 132.0) * h_sk
		h_h = (rumah_ne_tinggi if (rumah_ne_tinggi != null and rumah_ne_tinggi > 0.0) else 116.0) * h_sk
		h_gx = (rumah_ne_geser_x if rumah_ne_geser_x != null else 0.0)
		h_gy = (rumah_ne_geser_y if rumah_ne_geser_y != null else 0.0)
	elif (typeof(house_type) == TYPE_BOOL and bool(house_type)) or str(house_type) == "se":
		h_sk = 1.0 if (rumah_se_skala == null or rumah_se_skala <= 0.0) else float(rumah_se_skala)
		h_w = (rumah_se_lebar if (rumah_se_lebar != null and rumah_se_lebar > 0.0) else 132.0) * h_sk
		h_h = (rumah_se_tinggi if (rumah_se_tinggi != null and rumah_se_tinggi > 0.0) else 116.0) * h_sk
		h_gx = (rumah_se_geser_x if rumah_se_geser_x != null else 0.0)
		h_gy = (rumah_se_geser_y if rumah_se_geser_y != null else 0.0)
	else:
		h_sk = 1.0 if (rumah_atas_skala == null or rumah_atas_skala <= 0.0) else float(rumah_atas_skala)
		h_w = (rumah_atas_lebar if (rumah_atas_lebar != null and rumah_atas_lebar > 0.0) else 132.0) * h_sk
		h_h = (rumah_atas_tinggi if (rumah_atas_tinggi != null and rumah_atas_tinggi > 0.0) else 116.0) * h_sk
		h_gx = (rumah_atas_geser_x if rumah_atas_geser_x != null else 0.0)
		h_gy = (rumah_atas_geser_y if rumah_atas_geser_y != null else 0.0)

	_draw_texture_fit(h_tex, Rect2(sq_x + 12 + h_gx, sq_y + 6 + h_gy, h_w, h_h))

	_draw_fences_for_house(sq_x, sq_y, gate_key)

func _draw_fences_for_house(sq_x: float, sq_y: float, gate_key: String = "") -> void:
	var sk_kiri = 1.0 if (pagar_kiri_skala == null or pagar_kiri_skala <= 0.0) else float(pagar_kiri_skala)
	var sk_pintu = 1.0 if (pintu_pagar_skala == null or pintu_pagar_skala <= 0.0) else float(pintu_pagar_skala)
	var sk_kanan = 1.0 if (pagar_kanan_skala == null or pagar_kanan_skala <= 0.0) else float(pagar_kanan_skala)
	var sk_belakang = 1.0 if (pagar_belakang_skala == null or pagar_belakang_skala <= 0.0) else float(pagar_belakang_skala)
	var pw = pagar_belakang_panel_lebar * sk_belakang
	var pg = pagar_belakang_gap_panel

	# Pagar Belakang (3 panel)
	draw_texture_rect(tex_pagar, Rect2(sq_x + pagar_belakang_geser_x, sq_y - 4 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
	draw_texture_rect(tex_pagar, Rect2(sq_x + pw + pg + pagar_belakang_geser_x, sq_y - 4 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)
	draw_texture_rect(tex_pagar, Rect2(sq_x + (pw + pg) * 2.0 + pagar_belakang_geser_x, sq_y - 4 + pagar_belakang_geser_y, pw, 24 * sk_belakang), false)

	# Pagar Samping (2 panel tumpang tindih)
	var side_y = sq_y - 6 + pagar_samping_geser_y + gap_sudut_atas_samping
	var side_w = (pagar_samping_lebar if (pagar_samping_lebar != null and pagar_samping_lebar > 0.0) else 12.0)
	var side_total_h = (pagar_samping_tinggi if (pagar_samping_tinggi != null and pagar_samping_tinggi > 0.0) else 148.0)
	var n_panels = max(1, 2 if (pagar_samping_jumlah_panel == null or pagar_samping_jumlah_panel <= 0) else int(pagar_samping_jumlah_panel))
	var overlap_px = 16.0
	var panel_h = (side_total_h + (n_panels - 1) * overlap_px) / float(n_panels)
	var step_y = panel_h - overlap_px + (0.0 if pagar_samping_gap_panel == null else float(pagar_samping_gap_panel))

	for p in range(n_panels):
		var py = side_y + p * step_y
		# Pagar Samping Kiri
		_draw_side_fence(Rect2(sq_x - 3 + pagar_samping_kiri_geser_x, py, side_w, panel_h), true)
		# Pagar Samping Kanan
		_draw_side_fence(Rect2(sq_x + 156 - side_w + 3 + pagar_samping_kanan_geser_x, py, side_w, panel_h), false)
	
	# Pintu Pagar Tengah (Membuka geser mulus ke kiri saat didekati pemain)
	var slide_off: float = gate_slide_offsets.get(gate_key, 0.0)
	var gate_w = (pintu_pagar_lebar if (pintu_pagar_lebar != null and pintu_pagar_lebar > 0.0) else 32.0) * sk_pintu
	var gate_h = 30.0 * sk_pintu
	var gx = sq_x + 62.0 + (pintu_pagar_geser_x if pintu_pagar_geser_x != null else 0.0) + slide_off
	var gy = sq_y + 126.0 + (pintu_pagar_geser_y if pintu_pagar_geser_y != null else 0.0)
	draw_texture_rect(tex_pintu_pagar, Rect2(gx, gy, gate_w, gate_h), false)

	# Pagar Depan Kiri (Digambar di atas pintu pagar agar pintu bergeser rapi di balik pagar kiri)
	draw_texture_rect(tex_pagar, Rect2(sq_x + (pagar_kiri_geser_x if pagar_kiri_geser_x != null else 0.0), sq_y + 130.0 + (pagar_kiri_geser_y if pagar_kiri_geser_y != null else 0.0), (pagar_kiri_lebar if pagar_kiri_lebar != null else 62.0) * sk_kiri, 26.0 * sk_kiri), false)
	
	# Pagar Depan Kanan
	_draw_texture_flipped(tex_pagar, Rect2(sq_x + 94.0 + (pagar_kanan_geser_x if pagar_kanan_geser_x != null else 0.0), sq_y + 130.0 + (pagar_kanan_geser_y if pagar_kanan_geser_y != null else 0.0), (pagar_kanan_lebar if pagar_kanan_lebar != null else 62.0) * sk_kanan, 26.0 * sk_kanan), true, false)

func _draw_station_bench(pos: Vector2, w: float = 80.0, h: float = 24.0) -> void:
	draw_rect(Rect2(pos.x, pos.y, w, h), Color(0.48, 0.32, 0.18), true)
	draw_rect(Rect2(pos.x, pos.y, w, h), Color(0.25, 0.16, 0.08), false, 1.5)
	draw_line(Vector2(pos.x + 4, pos.y + 6), Vector2(pos.x + w - 4, pos.y + 6), Color(0.60, 0.42, 0.25), 1.0)
	draw_line(Vector2(pos.x + 4, pos.y + 16), Vector2(pos.x + w - 4, pos.y + 16), Color(0.60, 0.42, 0.25), 1.0)

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER GAMBAR TEMPAT PARKIR STASIUN (Parking Lot)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_parking_lot(rect: Rect2) -> void:
	var px := rect.position.x
	var py := rect.position.y
	var pw := rect.size.x   # 125
	var ph := rect.size.y   # 621

	# Aspal Lantai Parkir
	draw_rect(rect, COLOR_ASPHALT, true)

	# Trotoar Pembatas Sisi Barat (Gang) & Sisi Timur (Peron)
	draw_line(Vector2(px, py), Vector2(px, py + ph), COLOR_SIDEWALK_BEVEL, 3.0)
	draw_line(Vector2(px + pw, py), Vector2(px + pw, py + ph), COLOR_CURB_LINE, 2.5)

	# Marka Slot Parkir Mobil Horizontal (Putih Rapi)
	var slot_y_list := [py + 30.0, py + 95.0, py + 160.0, py + 225.0, py + 290.0, py + 410.0, py + 475.0, py + 540.0]
	for sy in slot_y_list:
		# Garis petak parkir
		draw_line(Vector2(px + 8, sy), Vector2(px + 85, sy), Color(0.92, 0.94, 0.98, 0.85), 2.0)
		# Pembatas ban / Wheel stop beton
		draw_rect(Rect2(px + 12, sy + 16, 6, 32), Color(0.70, 0.72, 0.76), true)
		draw_rect(Rect2(px + 12, sy + 16, 6, 32), Color(0.35, 0.38, 0.42), false, 1.0)

	# Area Parkir Sepeda / Motor di Tengah (y + 350)
	var bike_y := py + 350.0
	draw_rect(Rect2(px + 10, bike_y, 75, 45), Color(0.28, 0.30, 0.34), true)
	draw_rect(Rect2(px + 10, bike_y, 75, 45), COLOR_CURB_LINE, false, 1.5)
	# Rak besi sepeda
	for bx in range(int(px) + 18, int(px) + 80, 14):
		draw_rect(Rect2(bx, bike_y + 6, 4, 32), COLOR_STEEL_LIGHT, true)
		# Mini motor/sepeda
		draw_circle(Vector2(bx + 2, bike_y + 12), 3.0, Color(0.85, 0.25, 0.25))
		draw_circle(Vector2(bx + 2, bike_y + 32), 3.0, Color(0.20, 0.20, 0.20))

	# Taman Peneduh Parkiran (Tree Island) di Ujung Bawah
	var tree_y := py + 575.0
	draw_rect(Rect2(px + 10, tree_y, 75, 38), COLOR_GRASS, true)
	draw_rect(Rect2(px + 10, tree_y, 75, 38), COLOR_SIDEWALK_BEVEL, false, 2.0)
	draw_circle(Vector2(px + 45, tree_y + 18), 16.0, COLOR_TREE_DARK)
	draw_circle(Vector2(px + 45, tree_y + 18), 11.0, COLOR_TREE_LIGHT)

	# Tiang Lampu Jalan Parkiran
	for ly_pos in [py + 70.0, py + 260.0, py + 450.0]:
		draw_circle(Vector2(px + pw - 14, ly_pos), 5.0, COLOR_STEEL_DARK)
		draw_circle(Vector2(px + pw - 14, ly_pos), 3.0, Color(0.98, 0.95, 0.50)) # Lampu menyala

	# Jalur Penyeberangan Zebra (Pedestrian Walkway) Menuju Peron 1
	var cross_y := py + 348.0
	for zy in range(int(cross_y), int(cross_y) + 48, 10):
		draw_line(Vector2(px + pw - 24, zy), Vector2(px + pw + 8, zy), Color(0.92, 0.94, 0.98, 0.85), 4.0)


# ═══════════════════════════════════════════════════════════════════════════════
# HELPER GAMBAR GEDUNG UTAMA STASIUN TAMPAK ATAS (True Top-Down Station)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_station_building(rect: Rect2) -> void:
	_draw_station_building_to(self, rect)

func _draw_station_building_to(ci: CanvasItem, rect: Rect2) -> void:
	var bx := rect.position.x
	var by := rect.position.y
	var bw := rect.size.x   # e.g. 142
	var bh := rect.size.y   # e.g. 240

	# 1. Bayangan Jatuh Gedung ke Lantai (Elevated Drop Shadow 14px ke Kiri)
	var shadow_rect := Rect2(bx - 14, by + 12, bw + 6, bh)
	ci.draw_rect(shadow_rect, Color(0.06, 0.07, 0.10, 0.38), true)

	# 2. Atap Utama Mendominasi Tampak Atas (Roof: ~90% dari tinggi gedung)
	var roof_h := bh - 26.0 # Atap memenuhi hampir seluruh luas tampak atas
	var slope_w := bw * 0.50

	# Kemiringan Sisi Barat (Terakota Terang)
	ci.draw_rect(Rect2(bx, by, slope_w, roof_h), Color(0.68, 0.38, 0.24), true)

	# Kemiringan Sisi Timur (Terakota Gelap / Sisi Bayangan)
	ci.draw_rect(Rect2(bx + slope_w, by, slope_w, roof_h), Color(0.48, 0.24, 0.14), true)

	# Garis Lapisan Susunan Genteng (Stepped Tile Seams)
	for ty in range(int(by) + 18, int(by + roof_h) - 8, 22):
		ci.draw_line(Vector2(bx + 4, ty), Vector2(bx + slope_w - 2, ty), Color(0.56, 0.28, 0.16), 1.5)
		ci.draw_line(Vector2(bx + slope_w + 2, ty), Vector2(bx + bw - 4, ty), Color(0.34, 0.14, 0.07), 1.5)

	# Bubungan Puncak Utama Lurus (Center Ridge Line)
	ci.draw_line(Vector2(bx + slope_w, by), Vector2(bx + slope_w, by + roof_h), Color(0.92, 0.80, 0.65), 2.5)

	# Unit Pendingin AC Atap Stasiun Tampak Atas (Rooftop HVAC Unit)
	var hvac_rect := Rect2(bx + slope_w - 14, by + roof_h * 0.45, 28, 28)
	ci.draw_rect(Rect2(hvac_rect.position.x - 2, hvac_rect.position.y + 2, 30, 30), Color(0.06, 0.07, 0.10, 0.30), true) # Bayangan HVAC
	ci.draw_rect(hvac_rect, COLOR_STEEL_LIGHT, true)
	ci.draw_rect(hvac_rect, COLOR_STEEL_DARK, false, 1.5)
	ci.draw_line(Vector2(hvac_rect.position.x + 4, by + roof_h * 0.45 + 14), Vector2(hvac_rect.end.x - 4, by + roof_h * 0.45 + 14), COLOR_STEEL_DARK, 1.5)

	# 3. Kanopi Serambi & Pintu Masuk Bawah yang Proporsional (Hanya 26px di bagian bawah)
	var portico_y := by + roof_h
	ci.draw_rect(Rect2(bx, portico_y, bw, 26), COLOR_ROOM_STONE_B, true)
	# Bayangan overhanging atap ke serambi
	ci.draw_rect(Rect2(bx, portico_y, bw, 5), Color(0.08, 0.09, 0.12, 0.35), true)
	ci.draw_line(Vector2(bx, portico_y), Vector2(bx + bw, portico_y), COLOR_WALL_LINE, 2.0)

	# Pintu Masuk Stasiun Proporsional Tampak Atas
	var door_x := bx + bw * 0.5 - 24.0
	var door_w := 48.0
	var door_y := portico_y + 6.0
	ci.draw_rect(Rect2(door_x, door_y, door_w, 20), Color(0.12, 0.14, 0.18), true) # Pintu masuk
	ci.draw_rect(Rect2(door_x + 2, door_y + 2, door_w * 0.5 - 3, 16), Color(0.25, 0.42, 0.58), true)
	ci.draw_rect(Rect2(door_x + door_w * 0.5 + 1, door_y + 2, door_w * 0.5 - 3, 16), Color(0.25, 0.42, 0.58), true)

	# 4. Lisplang Luar Keliling Gedung
	ci.draw_rect(rect, COLOR_WALL_LINE, false, 2.5)


# ═══════════════════════════════════════════════════════════════════════════════
# HELPER GAMBAR KANOPI PENEDUH VERTIKAL ATAP BERSIH (Clean Platform Canopy)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_vertical_canopy(rect: Rect2) -> void:
	_draw_vertical_canopy_to(self, rect)

func _draw_vertical_canopy_to(ci: CanvasItem, rect: Rect2) -> void:
	var cx := rect.position.x
	var cy := rect.position.y
	var cw := rect.size.x   # e.g. 68
	var ch := rect.size.y   # e.g. 571

	# 1. Bayangan Jatuh Atap ke Lantai (Elevated Drop Shadow 12px ke Kiri)
	var shadow_rect := Rect2(cx - 12, cy + 10, cw + 6, ch)
	ci.draw_rect(shadow_rect, Color(0.06, 0.07, 0.10, 0.35), true)

	# 2. Struktur Atap Bersih 2-Tone (Lurus Murni Tampak Atas)
	var slope_w := cw * 0.50

	# Kemiringan Sisi Barat (Terang)
	ci.draw_rect(Rect2(cx, cy, slope_w, ch), Color(0.52, 0.50, 0.47), true)

	# Kemiringan Sisi Timur (Gelap)
	ci.draw_rect(Rect2(cx + slope_w, cy, slope_w, ch), Color(0.35, 0.33, 0.30), true)

	# Bubungan Puncak Tengah Atap (Center Ridge)
	ci.draw_line(Vector2(cx + slope_w, cy), Vector2(cx + slope_w, cy + ch), Color(0.88, 0.86, 0.84), 2.0)

	# Border Lisplang Luar Atap
	ci.draw_rect(Rect2(cx, cy, cw, ch), COLOR_WALL_LINE, false, 2.0)


# ═══════════════════════════════════════════════════════════════════════════════
# FUNGSI UTAMA: KOMPLEKS STASIUN KERETA API (Parkiran + Gedung Stasiun + Peron 2)
# ═══════════════════════════════════════════════════════════════════════════════
func _draw_train_station(rect: Rect2) -> void:
	var x  := rect.position.x   # 1860
	var y  := rect.position.y   # 690
	var rw := rect.size.x       # 300
	var rh := rect.size.y       # 621

	# ─────────────────────────────────────────────────────────────────────────
	# 1. AREA PARKIRAN STASIUN (Di Bagian Barat Blok: x = 1860 .. 1985)
	# ─────────────────────────────────────────────────────────────────────────
	var park_w := 125.0
	_draw_parking_lot(Rect2(x, y, park_w, rh))

	# ─────────────────────────────────────────────────────────────────────────
	# 2. PERON 1 & GEDUNG STASIUN BARAT (x = 1985 .. 2160)
	# ─────────────────────────────────────────────────────────────────────────
	var p1_x := x + park_w      # 1985
	var p1_w := rw - park_w     # 175
	var p1_rect := Rect2(p1_x, y, p1_w, rh)

	# Lantai Keramik Peron 1
	draw_rect(p1_rect, COLOR_ROOM_STONE_A, true)
	_draw_tile_pattern(p1_rect, COLOR_PLAZA_TILE_LINE)

	# Garis Kuning Pembatas Rel Peron 1 (Solid Bersih)
	var warn_w := (pembatas_kuning_lebar if (pembatas_kuning_lebar != null and pembatas_kuning_lebar > 0.0) else 20.0)
	var warn1_x := rect.end.x - warn_w + (pembatas_kuning_geser_x if pembatas_kuning_geser_x != null else 0.0)
	var warn1_y := y + (pembatas_kuning_geser_y if pembatas_kuning_geser_y != null else 0.0)
	draw_rect(Rect2(warn1_x, warn1_y, warn_w, rh), COLOR_HELIPAD_RING, true)
	draw_line(Vector2(warn1_x, warn1_y), Vector2(warn1_x, warn1_y + rh), COLOR_WALL_LINE, 1.5)
	draw_line(Vector2(warn1_x + warn_w, warn1_y), Vector2(warn1_x + warn_w, warn1_y + rh), COLOR_WALL_LINE, 3.0)

	# GEDUNG UTAMA STASIUN (Di Bagian Atas: y = 690 .. 935)
	var b_w := 142.0
	var b_h := 245.0
	_draw_station_building(Rect2(p1_x + 6, y + 8, b_w, b_h))

	# KANOPI PERON SELATAN (Area Terbuka / Perpanjangan Peron: y = 960 .. 1280)
	var c1_y := y + b_h + 20.0 # ~955
	var c1_h := rh - b_h - 40.0 # ~336
	var c1_w := 68.0
	var c1_x := warn1_x - c1_w - 16.0 # 2056
	_draw_vertical_canopy(Rect2(c1_x, c1_y, c1_w, c1_h))

	# Bangku Tunggu Kayu di Bawah Kanopi Selatan
	_draw_station_bench(Vector2(p1_x + 14, y + b_h + 50), 46.0, 18.0)

	# Fasilitas di Lantai Selatan (Bilik Telepon & Tempat Sampah)
	_draw_phone_booth(Rect2(p1_x + 12, y + rh - 72, 42, 60))
	draw_rect(Rect2(p1_x + 14, y + rh - 98, 10, 14), Color(0.22, 0.58, 0.28), true) # Hijau
	draw_rect(Rect2(p1_x + 14, y + rh - 98, 10, 14), COLOR_WALL_LINE, false, 1.5)
	draw_rect(Rect2(p1_x + 28, y + rh - 98, 10, 14), Color(0.25, 0.45, 0.75), true) # Biru
	draw_rect(Rect2(p1_x + 28, y + rh - 98, 10, 14), COLOR_WALL_LINE, false, 1.5)

	# ─────────────────────────────────────────────────────────────────────────
	# 3. PERON 2 TIMUR (Seberang Rel Kereta: x = 2280 .. 2420)
	# ─────────────────────────────────────────────────────────────────────────
	var p2_x := 2280.0
	var p2_w := 140.0
	var p2_rect := Rect2(p2_x, y, p2_w, rh)

	# Lantai Keramik Peron 2
	draw_rect(p2_rect, COLOR_ROOM_STONE_A, true)
	_draw_tile_pattern(p2_rect, COLOR_PLAZA_TILE_LINE)

	# Garis Kuning Pembatas Rel Peron 2 (Solid Bersih)
	var warn2_x := p2_x + (pembatas_kuning_geser_x if pembatas_kuning_geser_x != null else 0.0)
	var warn2_y := y + (pembatas_kuning_geser_y if pembatas_kuning_geser_y != null else 0.0)
	draw_rect(Rect2(warn2_x, warn2_y, warn_w, rh), COLOR_HELIPAD_RING, true)
	draw_line(Vector2(warn2_x + warn_w, warn2_y), Vector2(warn2_x + warn_w, warn2_y + rh), COLOR_WALL_LINE, 1.5)
	draw_line(Vector2(warn2_x, warn2_y), Vector2(warn2_x, warn2_y + rh), COLOR_WALL_LINE, 3.0)

	# Kanopi Peneduh Vertikal Bersih (Peron 2)
	_draw_vertical_canopy(Rect2(p2_x + 38, y + 25, 68, rh - 50))

	# Pagar Pembatas Ujung Timur Stasiun
	if pagar_kereta_tampilkan:
		var pk_sk = 1.0 if (pagar_kereta_skala == null or pagar_kereta_skala <= 0.0) else float(pagar_kereta_skala)
		var pk_x = p2_x + p2_w + (pagar_kereta_geser_x if pagar_kereta_geser_x != null else 0.0)
		var pk_y = y + (pagar_kereta_geser_y if pagar_kereta_geser_y != null else 0.0)
		var pk_h = (pagar_kereta_tinggi if (pagar_kereta_tinggi != null and pagar_kereta_tinggi > 0.0) else rh) * pk_sk
		draw_line(Vector2(pk_x, pk_y), Vector2(pk_x, pk_y + pk_h), COLOR_WALL_LINE, 3.5)

	# ─────────────────────────────────────────────────────────────────────────
	# 4. PENYEBERANGAN PEJALAN KAKI ANTAR PERON (Pedestrian Track Crossing)
	# ─────────────────────────────────────────────────────────────────────────
	var cross_y := y + 280.0
	var cross_h := 60.0
	# Papan kayu penyeberangan rel antar peron
	var cross_w := p2_x - warn1_x + warn_w # 2280 - 2140 + 20 = 160
	draw_rect(Rect2(warn1_x, cross_y, cross_w, cross_h), Color(0.42, 0.30, 0.22), true)
	for cx_bar in range(int(warn1_x) + 16, int(p2_x + warn_w), 20):
		draw_line(Vector2(cx_bar, cross_y), Vector2(cx_bar, cross_y + cross_h), Color(0.26, 0.18, 0.12), 1.5)
	# Strip kuning tepi penyeberangan
	draw_line(Vector2(warn1_x, cross_y), Vector2(p2_x + warn_w, cross_y), COLOR_HELIPAD_RING, 2.5)
	draw_line(Vector2(warn1_x, cross_y + cross_h), Vector2(p2_x + warn_w, cross_y + cross_h), COLOR_HELIPAD_RING, 2.5)

	# Rel baja abu-abu vertikal tetap tampak jelas & tembus memotong jalan penyeberangan kayu
	draw_line(Vector2(2185, cross_y), Vector2(2185, cross_y + cross_h), COLOR_TRACK_RAIL, 4.5)
	draw_line(Vector2(2185, cross_y), Vector2(2185, cross_y + cross_h), Color(0.85, 0.90, 0.98), 1.5)
	draw_line(Vector2(2255, cross_y), Vector2(2255, cross_y + cross_h), COLOR_TRACK_RAIL, 4.5)
	draw_line(Vector2(2255, cross_y), Vector2(2255, cross_y + cross_h), Color(0.85, 0.90, 0.98), 1.5)

	# Lampu Sinyal Penyeberangan Peron (Platform Crossing Signal Light)
	draw_circle(Vector2(warn1_x + 5, cross_y - 10), 5.0, COLOR_STEEL_DARK)
	draw_circle(Vector2(warn1_x + 5, cross_y - 10), 3.0, COLOR_ECG_GREEN)
	draw_circle(Vector2(p2_x + warn_w - 5, cross_y - 10), 5.0, COLOR_STEEL_DARK)
	draw_circle(Vector2(p2_x + warn_w - 5, cross_y - 10), 3.0, COLOR_ECG_GREEN)

	# Border Dinding Pembatas Blok Barat Stasiun
	draw_rect(rect, COLOR_WALL_LINE, false, 3.0)


func _draw_hospital_main_building(rect: Rect2) -> void:
	_draw_texture_fit(tex_hospital, Rect2(rect.position.x + 4, rect.position.y + 4, rect.size.x - 8, rect.size.y - 8))

func _draw_detective_house(rect: Rect2) -> void:
	draw_rect(rect, COLOR_PARQUET_WOOD, true)
	for py in range(int(rect.position.y) + 12, int(rect.end.y), 14):
		draw_line(Vector2(rect.position.x, py), Vector2(rect.end.x, py), COLOR_PARQUET_DARK, 1.0)

	_draw_texture_fit(tex_karpet, Rect2(rect.position.x + 28, rect.position.y + 40, 96, 75))
	_draw_texture_fit(tex_bed, Rect2(rect.position.x + 10, rect.position.y + 8, 48, 80))
	_draw_texture_fit(tex_lemari, Rect2(rect.position.x + 95, rect.position.y + 8, 52, 38))
	_draw_texture_fit(tex_laci, Rect2(rect.position.x + 10, rect.position.y + 96, 36, 42))

	draw_rect(Rect2(rect.position.x + 60, rect.position.y + 48, 42, 28), COLOR_CORKBOARD, true)
	draw_rect(Rect2(rect.position.x + 60, rect.position.y + 48, 42, 28), COLOR_DESK_RIM, false, 1.5)

	_draw_texture_fit(tex_surat, Rect2(rect.position.x + 64, rect.position.y + 52, 14, 10))
	_draw_texture_fit(tex_surat, Rect2(rect.position.x + 82, rect.position.y + 52, 14, 10))
	_draw_texture_fit(tex_surat, Rect2(rect.position.x + 72, rect.position.y + 64, 16, 10))

	draw_line(Vector2(rect.position.x + 71, rect.position.y + 57), Vector2(rect.position.x + 80, rect.position.y + 69), Color(0.9, 0.2, 0.2), 1.2)
	draw_line(Vector2(rect.position.x + 89, rect.position.y + 57), Vector2(rect.position.x + 80, rect.position.y + 69), Color(0.9, 0.2, 0.2), 1.2)

func _draw_hospital_morgue(_rect: Rect2) -> void:
	# Stub: Kamar jenazah lama telah digantikan oleh Kompleks WTC
	pass

func _draw_wtc_complex() -> void:
	if not wtc_tampilkan:
		return
	
	# ── 1. Penyeberangan Pejalan Kaki (Zebra Crossings) di Central Boulevard ───
	# Menghubungkan Plaza Finansial Utara dengan Distrik WTC Selatan
	_draw_zebra_crossing(Rect2(880, 551, 54, 137))
	_draw_zebra_crossing(Rect2(1270, 551, 54, 137))

	# ── 2. Lanskap & Fasilitas Plaza Utara ────────────────────────────────────
	# Jalur pejalan kaki, pohon-pohon peneduh di antara gedung, dan lampu jalan
	var north_gaps = [799.0, 991.0, 1184.0, 1376.0]
	for gx in north_gaps:
		_draw_wtc_tree_planter(Vector2(gx, 435.0))
		_draw_wtc_bench(Vector2(gx, 478.0), true)
		_draw_wtc_street_lamp(Vector2(gx, 375.0))
	
	# Lampu jalan sepanjang trotoar depan Plaza Utara
	for lx in [690.0, 890.0, 1090.0, 1290.0, 1480.0]:
		_draw_wtc_street_lamp(Vector2(lx, 536.0))

	# ── 3. Barisan Gedung Finansial Utara (5 Gedung Modern) ───────────────────
	if is_instance_valid(tex_gedung):
		var north_rects := get_wtc_north_towers()
		for idx in range(north_rects.size()):
			var b_rect: Rect2 = north_rects[idx]
			# Drop shadow lembut di belakang & bawah
			draw_rect(Rect2(b_rect.position.x - 3, b_rect.position.y - 6, b_rect.size.x + 6, 10), Color(0, 0, 0, 0.24), true)
			draw_rect(Rect2(b_rect.position.x - 4, b_rect.end.y - 4, b_rect.size.x + 8, 8), Color(0, 0, 0, 0.24), true)
			# Menggambar gedung dengan aspek rasio asli (GEDUNG_SRC_RECT)
			draw_texture_rect_region(tex_gedung, b_rect, GEDUNG_SRC_RECT, Color.WHITE)
			_draw_rooftop_props_to(self, b_rect, 10 + idx)

	# ── 4. Distrik Selatan: Kolam Refleksi Memorial WTC & Taman Pohon Ek ──────
	if wtc_pool_tampilkan:
		_draw_wtc_memorial_pool(get_wtc_memorial_pool_rect())
		_draw_wtc_oak_grove()

	# ── 5. Menara Kembar WTC (1 WTC & 2 WTC) ──────────────────────────────────
	if is_instance_valid(tex_gedung):
		var twin_rects := get_wtc_twin_towers()
		if twin_rects.size() >= 2:
			var t1_rect: Rect2 = twin_rects[0]
			var t2_rect: Rect2 = twin_rects[1]
			
			# Menara 1 (North Tower)
			draw_rect(Rect2(t1_rect.position.x - 4, t1_rect.position.y - 8, t1_rect.size.x + 8, 12), Color(0, 0, 0, 0.28), true)
			draw_rect(Rect2(t1_rect.position.x - 5, t1_rect.end.y - 4, t1_rect.size.x + 10, 8), Color(0, 0, 0, 0.28), true)
			draw_texture_rect_region(tex_gedung, t1_rect, GEDUNG_SRC_RECT, Color.WHITE)
			if wtc_spire_tampilkan:
				_draw_wtc_spire_to(self, t1_rect)
			
			# Menara 2 (South Tower)
			draw_rect(Rect2(t2_rect.position.x - 4, t2_rect.position.y - 8, t2_rect.size.x + 8, 12), Color(0, 0, 0, 0.28), true)
			draw_rect(Rect2(t2_rect.position.x - 5, t2_rect.end.y - 4, t2_rect.size.x + 10, 8), Color(0, 0, 0, 0.28), true)
			draw_texture_rect_region(tex_gedung, t2_rect, GEDUNG_SRC_RECT, Color.WHITE)
			_draw_wtc_observation_deck_to(self, t2_rect)

	# ── 6. Gedung Sayap Selatan (3 WTC & 4 WTC) ───────────────────────────────
	if is_instance_valid(tex_gedung):
		var flank_rects := get_wtc_south_flank_towers()
		for idx in range(flank_rects.size()):
			var b_rect: Rect2 = flank_rects[idx]
			draw_rect(Rect2(b_rect.position.x - 3, b_rect.position.y - 6, b_rect.size.x + 6, 10), Color(0, 0, 0, 0.24), true)
			draw_rect(Rect2(b_rect.position.x - 4, b_rect.end.y - 4, b_rect.size.x + 8, 8), Color(0, 0, 0, 0.24), true)
			draw_texture_rect_region(tex_gedung, b_rect, GEDUNG_SRC_RECT, Color.WHITE)
			_draw_rooftop_props_to(self, b_rect, 30 + idx)

	# ── 7. Fasilitas Plaza Selatan: Lampu Jalan, Bangku, & Jalur Pejalan Kaki ──
	# Bangku marmer di sisi promenade tengah
	_draw_wtc_bench(Vector2(1210.0, 750.0), false)
	_draw_wtc_bench(Vector2(1325.0, 750.0), false)
	_draw_wtc_bench(Vector2(1210.0, 830.0), false)
	_draw_wtc_bench(Vector2(1325.0, 830.0), false)
	_draw_wtc_bench(Vector2(1210.0, 910.0), false)
	_draw_wtc_bench(Vector2(1325.0, 910.0), false)
	
	# Lampu jalan di sekitar esplanade WTC Selatan
	for ly in [720.0, 820.0, 920.0, 1140.0, 1220.0]:
		_draw_wtc_street_lamp(Vector2(1175.0, ly))
		_draw_wtc_street_lamp(Vector2(1360.0, ly))

func _draw_wtc_memorial_pool(pool_rect: Rect2) -> void:
	# 1. Bibir Granit Luar
	var apron_rect = pool_rect.grow(8.0)
	draw_rect(apron_rect, Color(0.18, 0.19, 0.22), true)
	draw_rect(apron_rect, Color(0.12, 0.13, 0.15), false, 2.0)
	
	# 2. Dinding Perunggu Memorial (Bronze Parapet) dengan panel nama
	draw_rect(pool_rect, Color(0.36, 0.28, 0.18), true)
	draw_rect(pool_rect, Color(0.22, 0.17, 0.11), false, 1.5)
	for px in range(int(pool_rect.position.x) + 12, int(pool_rect.end.x) - 8, 20):
		draw_line(Vector2(px, pool_rect.position.y), Vector2(px, pool_rect.position.y + 6), Color(0.22, 0.17, 0.11), 1.0)
		draw_line(Vector2(px, pool_rect.end.y - 6), Vector2(px, pool_rect.end.y), Color(0.22, 0.17, 0.11), 1.0)
	for py in range(int(pool_rect.position.y) + 12, int(pool_rect.end.y) - 8, 20):
		draw_line(Vector2(pool_rect.position.x, py), Vector2(pool_rect.position.x + 6, py), Color(0.22, 0.17, 0.11), 1.0)
		draw_line(Vector2(pool_rect.end.x - 6, py), Vector2(pool_rect.end.x, py), Color(0.22, 0.17, 0.11), 1.0)

	# 3. Air Terjun Bertingkat / Weir Cascade Rim (Buih putih cyan)
	var water_rect = pool_rect.grow(-6.0)
	draw_rect(water_rect, Color(0.65, 0.88, 0.95, 0.85), true)
	
	# 4. Kolam Air Refleksi Biru Dalam
	var basin_rect = water_rect.grow(-4.0)
	draw_rect(basin_rect, Color(0.06, 0.20, 0.32), true)
	
	# Kilauan gelombang halus
	for ry in range(int(basin_rect.position.y) + 8, int(basin_rect.end.y) - 8, 12):
		var rx1 = basin_rect.position.x + 6.0 + float((ry % 7) * 5)
		var rx2 = min(rx1 + 32.0, basin_rect.end.x - 6.0)
		if rx2 > rx1:
			draw_line(Vector2(rx1, ry), Vector2(rx2, ry), Color(0.25, 0.65, 0.85, 0.40), 1.5)
	
	# 5. Lubang Pusat Kehampaan / Void Drain (Air jatuh ke jurang hitam tak berujung)
	var center_void = Rect2(
		basin_rect.position.x + (basin_rect.size.x - 50.0) * 0.5,
		basin_rect.position.y + (basin_rect.size.y - 36.0) * 0.5,
		50.0, 36.0
	)
	draw_rect(center_void.grow(2.0), Color(0.55, 0.82, 0.92, 0.9), false, 2.0)
	draw_rect(center_void, Color(0.02, 0.03, 0.04), true)
	draw_rect(center_void, Color(0.0, 0.0, 0.0, 0.8), false, 1.5)

func _draw_wtc_oak_grove() -> void:
	var tree_positions: Array[Vector2] = [
		Vector2(1148, 965), Vector2(1148, 1020), Vector2(1148, 1075),
		Vector2(1388, 965), Vector2(1388, 1020), Vector2(1388, 1075),
		Vector2(1205, 1115), Vector2(1268, 1115), Vector2(1331, 1115)
	]
	for pos in tree_positions:
		# Kisi lantai pohon granit
		draw_rect(Rect2(pos.x - 12, pos.y - 12, 24, 24), Color(0.20, 0.22, 0.25), true)
		draw_rect(Rect2(pos.x - 12, pos.y - 12, 24, 24), Color(0.35, 0.38, 0.42), false, 1.0)
		draw_circle(pos, 8.0, Color(0.18, 0.16, 0.14))
		# Tajuk pohon ek rimbun berlapis
		draw_circle(pos + Vector2(2, 2), 12.0, Color(0, 0, 0, 0.22))
		draw_circle(pos, 11.0, Color(0.20, 0.30, 0.12))
		draw_circle(pos + Vector2(-2, -2), 9.0, Color(0.35, 0.48, 0.18))
		draw_circle(pos + Vector2(-3, -3), 5.0, Color(0.48, 0.60, 0.24))

func _draw_zebra_crossing(rect: Rect2) -> void:
	# Strip kuning taktil penyeberangan di kedua ujung trotoar
	draw_rect(Rect2(rect.position.x - 2, rect.position.y - 2, rect.size.x + 4, 4), Color(0.85, 0.72, 0.20), true)
	draw_rect(Rect2(rect.position.x - 2, rect.end.y - 2, rect.size.x + 4, 4), Color(0.85, 0.72, 0.20), true)
	# Garis putih zebra crossing sejajar arah lalu lintas jalan
	for sy in range(int(rect.position.y) + 4, int(rect.end.y) - 6, 14):
		draw_rect(Rect2(rect.position.x, sy, rect.size.x, 8.0), Color(0.95, 0.95, 0.96, 0.92), true)

func _draw_wtc_street_lamp(pos: Vector2) -> void:
	# Pendaran cahaya hangat
	draw_circle(pos, 16.0, Color(1.0, 0.92, 0.65, 0.15))
	draw_circle(pos, 8.0, Color(1.0, 0.95, 0.75, 0.30))
	# Tiang lampu modern
	draw_circle(pos, 3.5, Color(0.35, 0.38, 0.42))
	draw_circle(pos, 2.0, Color(1.0, 0.98, 0.85))

func _draw_wtc_bench(pos: Vector2, horizontal: bool = true) -> void:
	var bw = 24.0 if horizontal else 8.0
	var bh = 8.0 if horizontal else 24.0
	var rect = Rect2(pos.x - bw * 0.5, pos.y - bh * 0.5, bw, bh)
	# Kaki logam
	draw_rect(rect.grow(1.5), Color(0.20, 0.22, 0.25), true)
	# Dudukan marmer/kayu
	draw_rect(rect, Color(0.60, 0.48, 0.35), true)
	draw_rect(rect, Color(0.28, 0.22, 0.16), false, 1.0)

func _draw_wtc_tree_planter(pos: Vector2) -> void:
	# Kotak pot tanaman granit
	var pr = Rect2(pos.x - 14, pos.y - 14, 28, 28)
	draw_rect(pr, Color(0.22, 0.24, 0.28), true)
	draw_rect(pr, Color(0.40, 0.44, 0.48), false, 1.5)
	draw_circle(pos, 10.0, Color(0.18, 0.16, 0.14))
	# Pohon ornamen taman
	draw_circle(pos + Vector2(2, 2), 12.0, Color(0, 0, 0, 0.25))
	draw_circle(pos, 11.0, Color(0.20, 0.32, 0.14))
	draw_circle(pos + Vector2(-2, -2), 9.0, Color(0.36, 0.50, 0.20))
	draw_circle(pos + Vector2(-3, -3), 5.0, Color(0.50, 0.64, 0.26))

func _draw_wtc_spire_to(ci: CanvasItem, t_rect: Rect2) -> void:
	if not is_instance_valid(ci):
		return
	var cx: float = t_rect.position.x + t_rect.size.x * 0.5
	var roof_y: float = t_rect.position.y
	var spire_top: float = roof_y - 52.0
	
	# Kabel penahan (guy wires) ke sudut atap menara
	ci.draw_line(Vector2(cx, roof_y - 28.0), Vector2(t_rect.position.x + 8.0, roof_y + 4.0), Color(0.70, 0.74, 0.80, 0.55), 1.0)
	ci.draw_line(Vector2(cx, roof_y - 28.0), Vector2(t_rect.end.x - 8.0, roof_y + 4.0), Color(0.70, 0.74, 0.80, 0.55), 1.0)
	
	# Dudukan dasar tiang antena
	ci.draw_rect(Rect2(cx - 8.0, roof_y - 4.0, 16.0, 6.0), Color(0.40, 0.44, 0.48), true)
	ci.draw_rect(Rect2(cx - 5.0, roof_y - 8.0, 10.0, 4.0), Color(0.55, 0.58, 0.62), true)
	
	# Batang utama antena perak (spire mast)
	ci.draw_line(Vector2(cx, roof_y - 8.0), Vector2(cx, spire_top), Color(0.85, 0.88, 0.92), 2.5)
	for sy in range(int(spire_top) + 8, int(roof_y) - 8, 8):
		var sw: float = float(sy - spire_top) * 0.12 + 2.0
		ci.draw_line(Vector2(cx - sw, sy), Vector2(cx + sw, sy), Color(0.75, 0.78, 0.82), 1.0)
	
	# Lampu suar merah penerbangan (aviation warning beacon) di puncak antena
	ci.draw_circle(Vector2(cx, spire_top), 4.5, Color(1.0, 0.25, 0.25, 0.35))
	ci.draw_circle(Vector2(cx, spire_top), 2.5, Color(1.0, 0.15, 0.15, 1.0))

func _draw_wtc_observation_deck_to(ci: CanvasItem, t_rect: Rect2) -> void:
	if not is_instance_valid(ci):
		return
	var rx: float = t_rect.position.x + 8.0
	var ry: float = t_rect.position.y + 4.0
	var rw: float = t_rect.size.x - 16.0
	var rh: float = 24.0
	
	# Lantai dek observasi
	ci.draw_rect(Rect2(rx, ry, rw, rh), Color(0.30, 0.32, 0.36), true)
	# Pagar kaca pengaman perimeter
	ci.draw_rect(Rect2(rx, ry, rw, rh), Color(0.50, 0.75, 0.90, 0.75), false, 1.5)
	# Teropong pengamatan panorama
	for bx in [rx + 12.0, rx + rw * 0.5, rx + rw - 12.0]:
		ci.draw_line(Vector2(bx, ry + 2.0), Vector2(bx, ry + 7.0), Color(0.85, 0.88, 0.90), 1.5)
		ci.draw_circle(Vector2(bx, ry + 2.0), 1.5, Color(0.95, 0.95, 0.98))
	# Paviliun kaca / rumah lift di tengah atap
	var pav_w: float = rw * 0.45
	var pav_h: float = 12.0
	var pav_rect := Rect2(rx + (rw - pav_w) * 0.5, ry + (rh - pav_h) * 0.5, pav_w, pav_h)
	ci.draw_rect(pav_rect, Color(0.20, 0.35, 0.48, 0.85), true)
	ci.draw_rect(pav_rect, Color(0.60, 0.80, 0.95), false, 1.0)

func _draw_city_road_network() -> void:
	# ── 1. Trotoar & Lapisan Dasar Aspal (Seamless Asphalt Base) ─────────────
	var road_polys = [
		Rect2(-2,   190, 2164, 136),  # North Blvd
		Rect2(514,  190,  127, 598),  # West Vertical Road (y=190..788)
		Rect2(190,  784,  451, 169),  # Mid-West Plaza Road in front of Police (x=190..641, y=784..953)
		Rect2(355,  949,  112, 364),  # South-West Street between Police & Hospital (x=355..467, y=949..1313)
		Rect2(514,  547, 1504, 145),  # Central Blvd (x=514..2018, y=547..692)
		Rect2(1534, 190,   94, 1057), # East Vertical Avenue
		Rect2(2014, 190,  148, 502),  # Far-East Highway
		Rect2(-2,   1243, 1864, 70),  # South Ring Road
	]
	for r in road_polys:
		draw_rect(r, COLOR_SIDEWALK_BEVEL, true)

	var asphalts: Array[Rect2] = [
		Rect2(0,    192,  2160, 132),  # North Blvd         (y=192..324)
		Rect2(516,  192,   123, 594),  # West Vertical       (x=516..639, y=192..786)
		Rect2(192,  786,   447, 165),  # Mid-West Plaza Road in front of Police (x=192..639, y=786..951)
		Rect2(357,  951,   108, 360),  # SW Street Polisi-RS (x=357..465, y=951..1311)
		Rect2(516,  549,  1500, 141),  # Central Blvd        (x=516..2016, y=549..690)
		Rect2(1536, 192,    90, 1053), # East Vertical Avenue (x=1536..1626, y=192..1245)
		Rect2(2016, 192,   144, 498),  # Far-East Highway    (x=2016..2160, y=192..690)
		Rect2(0,    1245, 1860, 66),   # South Ring Road     (x=0..1860, y=1245..1311)
	]
	for r in asphalts:
		draw_rect(r, COLOR_ASPHALT, true)

	# ── 2. Garis Batas Tepi Jalan / Bahu Jalan (Curbs - Hanya di Dinding) ────
	# North Boulevard
	draw_line(Vector2(0, 196), Vector2(2160, 196), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(0, 320), Vector2(516, 320), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(639, 320), Vector2(1536, 320), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1626, 320), Vector2(2016, 320), COLOR_CURB_LINE, 2.0)

	# Central Boulevard
	draw_line(Vector2(516, 553), Vector2(2016, 553), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(639, 686), Vector2(1536, 686), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1626, 686), Vector2(1792, 686), COLOR_CURB_LINE, 2.0)

	# West Vertical Road
	draw_line(Vector2(520, 324), Vector2(520, 786), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(635, 324), Vector2(635, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(635, 690), Vector2(635, 947), COLOR_CURB_LINE, 2.0)

	# East Vertical Avenue
	draw_line(Vector2(1540, 324), Vector2(1540, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1622, 324), Vector2(1622, 549), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1540, 690), Vector2(1540, 1245), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1622, 690), Vector2(1622, 849), COLOR_CURB_LINE, 2.0)

	# Mid-West Street & South-West Street (Jalan Depan & Samping Kantor Polisi / RS)
	draw_line(Vector2(192, 790), Vector2(516, 790), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(192, 947), Vector2(357, 947), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(361, 951), Vector2(361, 1080), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(361, 1150), Vector2(361, 1245), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(461, 947), Vector2(461, 1245), COLOR_CURB_LINE, 2.0)

	# South Ring Road Bottom
	draw_line(Vector2(0, 1307), Vector2(1860, 1307), COLOR_CURB_LINE, 2.0)

	# ── 3. Garis Putus-Putus Jalur (Berhenti Rapi Sebelum Persimpangan) ───────
	# North Boulevard (y = 258)
	_draw_lane_dashes(Vector2(20, 258), Vector2(496, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(659, 258), Vector2(1516, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1646, 258), Vector2(1996, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(2036, 258), Vector2(2140, 258), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# Central Boulevard (y = 619)
	_draw_lane_dashes(Vector2(659, 619), Vector2(1516, 619), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1646, 619), Vector2(1996, 619), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# West Vertical Road (x = 577)
	_draw_lane_dashes(Vector2(577, 344), Vector2(577, 529), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(577, 710), Vector2(577, 766), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# Mid-West Street (y = 865 di depan Kantor Polisi)
	_draw_lane_dashes(Vector2(212, 865), Vector2(337, 865), 24.0, 16.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(485, 865), Vector2(619, 865), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# South-West Street (x = 411 antara Polisi & RS)
	_draw_lane_dashes(Vector2(411, 965), Vector2(411, 1225), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# East Vertical Avenue (x = 1581)
	_draw_lane_dashes(Vector2(1581, 344), Vector2(1581, 529), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(1581, 710), Vector2(1581, 1225), 20.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# Far-East Highway (x = 2088)
	_draw_lane_dashes(Vector2(2088, 344), Vector2(2088, 529), 24.0, 16.0, COLOR_LANE_DASH, 2.0)

	# South Ring Road (y = 1278)
	_draw_lane_dashes(Vector2(20, 1278), Vector2(337, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(485, 1278), Vector2(1516, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)
	_draw_lane_dashes(Vector2(1646, 1278), Vector2(1840, 1278), 24.0, 16.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.6), 1.5)

	# ── 4. Garis Berhenti / Stop Bar di Setiap Persimpangan ──────────────────
	# Persimpangan North Blvd & West Vertical
	_draw_stop_bar(Vector2(522, 328), Vector2(633, 328))
	_draw_stop_bar(Vector2(512, 200), Vector2(512, 316))
	_draw_stop_bar(Vector2(643, 200), Vector2(643, 316))

	# Persimpangan North Blvd & East Vertical
	_draw_stop_bar(Vector2(1542, 328), Vector2(1620, 328))
	_draw_stop_bar(Vector2(1532, 200), Vector2(1532, 316))
	_draw_stop_bar(Vector2(1630, 200), Vector2(1630, 316))

	# Persimpangan Central Blvd & West Vertical
	_draw_stop_bar(Vector2(522, 545), Vector2(633, 545))
	_draw_stop_bar(Vector2(643, 557), Vector2(643, 682))

	# Persimpangan Central Blvd & East Vertical (Perempatan Pusat)
	_draw_stop_bar(Vector2(1542, 545), Vector2(1620, 545))
	_draw_stop_bar(Vector2(1542, 694), Vector2(1620, 694))
	_draw_stop_bar(Vector2(1532, 557), Vector2(1532, 682))
	_draw_stop_bar(Vector2(1630, 557), Vector2(1630, 682))

	# Persimpangan Jalan Polisi & Rumah Sakit (South-West Street)
	_draw_stop_bar(Vector2(361, 947), Vector2(461, 947))
	_draw_stop_bar(Vector2(361, 1243), Vector2(461, 1243))
	_draw_stop_bar(Vector2(512, 790), Vector2(512, 947))

	# Persimpangan Far-East Highway
	_draw_stop_bar(Vector2(2012, 200), Vector2(2012, 316))
	_draw_stop_bar(Vector2(2012, 557), Vector2(2012, 682))

func _draw_lane_dashes(p1: Vector2, p2: Vector2, dash_len: float = 24.0, gap_len: float = 16.0, color: Color = COLOR_LANE_DASH, width: float = 2.0) -> void:
	var total_dist = p1.distance_to(p2)
	if total_dist <= dash_len:
		return
	var dir = (p2 - p1).normalized()
	var cur_dist = 0.0
	while cur_dist + dash_len <= total_dist:
		var start_pt = p1 + dir * cur_dist
		var end_pt = p1 + dir * (cur_dist + dash_len)
		draw_line(start_pt, end_pt, color, width)
		cur_dist += dash_len + gap_len

func _draw_stop_bar(p1: Vector2, p2: Vector2) -> void:
	draw_line(p1, p2, Color(1, 1, 1, 0.85), 3.0)

func _draw_courtyard_garden(center: Vector2, radius: float) -> void:
	draw_circle(center, radius, COLOR_GRASS)
	draw_arc(center, radius, 0, TAU, 24, COLOR_SIDEWALK_BEVEL, 2.0)
	draw_circle(center + Vector2(-8, -6), radius * 0.45, COLOR_TREE_DARK)
	draw_circle(center + Vector2(-10, -8), radius * 0.35, COLOR_TREE_LIGHT)
	draw_circle(center + Vector2(10, 8), radius * 0.38, COLOR_TREE_DARK)
	draw_circle(center + Vector2(8, 6), radius * 0.28, COLOR_TREE_LIGHT)

func _draw_room_pavement(rect: Rect2, color: Color) -> void:
	draw_rect(rect, color, true)
	_draw_tile_pattern(rect, COLOR_PLAZA_TILE_LINE)

func _draw_tile_pattern(rect: Rect2, color: Color) -> void:
	for x in range(int(rect.position.x) + 30, int(rect.end.x), 30):
		draw_line(Vector2(x, rect.position.y), Vector2(x, rect.end.y), color, 0.8)
	for y in range(int(rect.position.y) + 30, int(rect.end.y), 30):
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), color, 0.8)

func _draw_desk(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(2, 2), rect.size), Color(0, 0, 0, 0.25), true)
	draw_rect(rect, COLOR_DESK_WOOD, true)
	draw_rect(rect, COLOR_DESK_RIM, false, 2.0)
	if rect.size.x > rect.size.y:
		draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + 2),
				  Vector2(rect.position.x + rect.size.x * 0.5, rect.end.y - 2), COLOR_DESK_RIM, 1.5)

func _draw_poi_badge(pos: Vector2, _label: String, color: Color) -> void:
	var pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.004)
	draw_circle(pos, 20.0 + pulse * 4.0, Color(color.r, color.g, color.b, 0.25))
	draw_circle(pos, 9.0, color)
	draw_circle(pos, 5.0, Color(1, 1, 1, 0.95))
