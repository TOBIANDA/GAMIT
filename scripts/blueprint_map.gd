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
var tex_jalan_lurus: Texture2D
var tex_jalan_simpang3: Texture2D
var tex_jalan_simpang4: Texture2D
var _cached_gedung_polys: Array[PackedVector2Array] = []
var _cached_gedung_size := Vector2(951.0, 2031.0)
var _cached_rumah_polys: Array[PackedVector2Array] = []
var _cached_rumah_size := Vector2.ZERO
var _cached_police_polys: Array[PackedVector2Array] = []
var _cached_police_size := Vector2.ZERO
var _cached_hospital_polys: Array[PackedVector2Array] = []
var _cached_hospital_size := Vector2.ZERO

var street_lights: Array[PointLight2D] = []
var light_flicker_timer: float = 0.0

@export_group("0. Street Lamps & Atmosphere")
@export var street_lamp_energy: float = 0.48:
	set(val):
		street_lamp_energy = val
		for light in street_lights:
			if is_instance_valid(light):
				light.energy = street_lamp_energy
@export var street_lamp_scale: float = 0.95:
	set(val):
		street_lamp_scale = val
		for light in street_lights:
			if is_instance_valid(light):
				light.texture_scale = street_lamp_scale

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
@export var telepon_jalan_tampilkan: bool = false:
	set(val):
		telepon_jalan_tampilkan = val
		queue_redraw()
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

@export_group("12. Penanda Lokasi (POI Badges)")
@export var poi_badge_tampilkan: bool = false:
	set(val):
		poi_badge_tampilkan = val
		queue_redraw()

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
@export var gedung_nw_lebar_dasar: float = 76.0:
	set(val):
		gedung_nw_lebar_dasar = 76.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_nw_jarak_x: float = 42.0:
	set(val):
		gedung_nw_jarak_x = 42.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_jarak_y: float = 186.0:
	set(val):
		gedung_nw_jarak_y = 186.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_zigzag: bool = false:
	set(val):
		gedung_nw_zigzag = val
		queue_redraw()
@export var gedung_nw_zigzag_offset: float = 0.0:
	set(val):
		gedung_nw_zigzag_offset = 0.0 if val == null else float(val)
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
@export var gedung_nw_kolam_x: float = 160.0:
	set(val):
		gedung_nw_kolam_x = 160.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_kolam_y: float = 696.0:
	set(val):
		gedung_nw_kolam_y = 696.0 if val == null else float(val)
		queue_redraw()
@export var gedung_nw_kolam_lebar: float = 194.0:
	set(val):
		gedung_nw_kolam_lebar = 194.0 if (val == null or val <= 0.0) else float(val)
		queue_redraw()
@export var gedung_nw_kolam_tinggi: float = 64.0:
	set(val):
		gedung_nw_kolam_tinggi = 64.0 if (val == null or val <= 0.0) else float(val)
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
	var rows: int = max(1, gedung_nw_baris if gedung_nw_baris != null else 2)
	
	var base_w: float = (gedung_nw_lebar_dasar if (gedung_nw_lebar_dasar != null and gedung_nw_lebar_dasar > 0.0) else 76.0) * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	
	var step_x: float = (gedung_nw_jarak_x if gedung_nw_jarak_x != null else 42.0) * sk
	var step_y: float = (gedung_nw_jarak_y if gedung_nw_jarak_y != null else 186.0) * sk
	
	var start_x: float = 42.0 + gx
	var start_y: float = 330.0 + gy
	
	var stagger: float = (gedung_nw_zigzag_offset if (gedung_nw_zigzag and gedung_nw_zigzag_offset != null) else 0.0) * sk * 0.5
	
	var rects: Array[Rect2] = []
	for r in range(rows):
		var cur_y: float = start_y + float(r) * step_y
		var row_offset_x: float = (-stagger if (r % 2 == 0) else stagger)
		for c in range(cols):
			var cur_x: float = start_x + float(c) * (base_w + step_x) + row_offset_x
			rects.append(Rect2(cur_x, cur_y, base_w, base_h))
	return rects

func get_nw_gedung_columns() -> Array[Rect2]:
	var sk: float = 1.0 if (gedung_nw_skala == null or gedung_nw_skala <= 0.0) else float(gedung_nw_skala)
	var gx: float = (gedung_nw_geser_x if gedung_nw_geser_x != null else 0.0)
	var gy: float = (gedung_nw_geser_y if gedung_nw_geser_y != null else 0.0)
	var cols: int = max(1, gedung_nw_kolom if gedung_nw_kolom != null else 4)
	var rows: int = max(1, gedung_nw_baris if gedung_nw_baris != null else 2)
	
	var base_w: float = (gedung_nw_lebar_dasar if (gedung_nw_lebar_dasar != null and gedung_nw_lebar_dasar > 0.0) else 76.0) * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var step_x: float = (gedung_nw_jarak_x if gedung_nw_jarak_x != null else 42.0) * sk
	var step_y: float = (gedung_nw_jarak_y if gedung_nw_jarak_y != null else 186.0) * sk
	var start_x: float = 42.0 + gx
	var start_y: float = 330.0 + gy
	var total_col_h: float = float(rows - 1) * step_y + base_h
	
	var stagger: float = (gedung_nw_zigzag_offset if (gedung_nw_zigzag and gedung_nw_zigzag_offset != null) else 0.0) * sk * 0.5
	
	var col_rects: Array[Rect2] = []
	for c in range(cols):
		var cur_x: float = start_x + float(c) * (base_w + step_x) - stagger
		var col_w: float = base_w + stagger * 2.0
		col_rects.append(Rect2(cur_x, start_y, col_w, total_col_h))
	return col_rects

func get_benjolan_gedung_rect() -> Rect2:
	var sk: float = 1.0 if (gedung_benjolan_skala == null or gedung_benjolan_skala <= 0.0) else float(gedung_benjolan_skala)
	var gx: float = (gedung_benjolan_geser_x if gedung_benjolan_geser_x != null else 0.0)
	var gy: float = (gedung_benjolan_geser_y if gedung_benjolan_geser_y != null else 0.0)
	var base_w: float = (gedung_nw_lebar_dasar if (gedung_nw_lebar_dasar != null and gedung_nw_lebar_dasar > 0.0) else 76.0) * sk
	var base_h: float = base_w * GEDUNG_ASPECT_RATIO
	var bx: float = 42.0 + gx # Sejajar persis dengan Kolom 0 Gedung NW
	var by: float = 933.0 - base_h + gy
	return Rect2(bx, by, base_w, base_h)

func get_nw_kolam_water_rect() -> Rect2:
	var kx: float = (gedung_nw_kolam_x if gedung_nw_kolam_x != null else 160.0)
	var ky: float = (gedung_nw_kolam_y if gedung_nw_kolam_y != null else 696.0)
	var kw: float = (gedung_nw_kolam_lebar if (gedung_nw_kolam_lebar != null and gedung_nw_kolam_lebar > 0.0) else 194.0)
	var kh: float = (gedung_nw_kolam_tinggi if (gedung_nw_kolam_tinggi != null and gedung_nw_kolam_tinggi > 0.0) else 64.0)
	return Rect2(kx, ky, kw, kh)
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
@export var gedung_rs_tampilkan: bool = false:
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
var gate_open_ratios: Dictionary = {}
var gate_colliders: Dictionary = {}
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
		_setup_street_lights()
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

func _is_gate_openable(key: String) -> bool:
	# Hanya pintu pagar rumah MC (top_6) dan rumah Ibu (se_2) yang bisa dibuka sama sekali!
	return key == "top_6" or key == "se_2"

func _update_gate_interaction(gate_center: Vector2, key: String, p_pos: Vector2, delta: float) -> bool:
	if not _is_gate_openable(key):
		gate_open_ratios[key] = 0.0
		gate_slide_offsets[key] = 0.0
		if gate_colliders.has(key) and is_instance_valid(gate_colliders[key]):
			gate_colliders[key].set_deferred("disabled", false)
		return false

	var dist := p_pos.distance_to(gate_center)
	# Membuka terdorong berayun saat pemain mendekati / menabrak pagar (jarak < 52px)
	var target_open: float = 1.0 if dist < 52.0 else 0.0
	var cur_open: float = gate_open_ratios.get(key, 0.0)

	if cur_open <= 0.02 and target_open > 0.0:
		_play_gate_open_sound(gate_center)

	var next_open: float = move_toward(cur_open, target_open, delta * 3.8)
	var changed: bool = (abs(cur_open - next_open) > 0.005)

	gate_open_ratios[key] = next_open
	gate_slide_offsets[key] = -28.0 * next_open

	if gate_colliders.has(key) and is_instance_valid(gate_colliders[key]):
		if next_open > 0.15:
			gate_colliders[key].set_deferred("disabled", true)
		elif next_open <= 0.05:
			gate_colliders[key].set_deferred("disabled", false)

	return changed

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if not is_instance_valid(player_cached):
		player_cached = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if not is_instance_valid(player_cached):
			player_cached = get_node_or_null("../Player") as CharacterBody2D

	var needs_redraw := false
	var p_pos := player_cached.global_position if is_instance_valid(player_cached) else Vector2(-9999, -9999)

	if not street_lights.is_empty():
		light_flicker_timer += delta * 2.8
		for idx in range(min(street_lights.size(), 24)):
			var l = street_lights[idx]
			if is_instance_valid(l):
				l.energy = 0.65 + sin(light_flicker_timer + float(idx) * 1.3) * 0.03

	# Update ayunan buka pintu pagar saat didorong pemain (Membuka Berputar Masuk ke Halaman)
	for i in range(11):
		var sq_x: float = (13.0 + float(i) * 62.0) * 3.0
		var sq_y: float = 36.0
		var gate_center := Vector2(sq_x + 78.0, sq_y + 138.0)
		var key := "top_%d" % i
		if _update_gate_interaction(gate_center, key, p_pos, delta):
			needs_redraw = true

	# Update ayunan buka pintu pagar 3 Rumah Tenggara
	var hy_list: Array[float] = [705.0, 880.0, 1055.0]
	for idx in range(3):
		var sq_x: float = 1636.0
		var sq_y: float = hy_list[idx]
		var gate_center := Vector2(sq_x + 78.0, sq_y + 138.0)
		var key := "se_%d" % idx
		if _update_gate_interaction(gate_center, key, p_pos, delta):
			needs_redraw = true

	# Update ayunan buka pintu pagar 2 Rumah NE
	var ne_positions_proc = get_ne_house_positions()
	for idx in range(ne_positions_proc.size()):
		var n_pos: Vector2 = ne_positions_proc[idx]
		var gate_center := Vector2(n_pos.x + 78.0, n_pos.y + 138.0)
		var key := "ne_%d" % idx
		if _update_gate_interaction(gate_center, key, p_pos, delta):
			needs_redraw = true

	if needs_redraw:
		queue_redraw()
	if is_instance_valid(roof_overlay_node):
		roof_overlay_node.queue_redraw()

class RoofOverlayNode extends Node2D:
	var map: Node2D = null

	# Rasio area atap rumah (bagian atas) vs dinding depan pada top-down.
	const ROOF_RATIO := 0.65
	# Rasio fasad atas gedung pencakar langit yang menutupi pemain saat berjalan di belakang gedung.
	# Sisanya (bawah 32%) adalah lantai/fondasi dasar (footprint) tempat kolisi solid berada.
	const GEDUNG_UPPER_RATIO := 0.68

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
		
		# Efek X-Ray Transparan saat pemain berada di belakang atap rumah
		var is_behind := false
		if is_instance_valid(map) and is_instance_valid(map.player_cached):
			var p_pos: Vector2 = map.player_cached.global_position
			is_behind = (p_pos.x >= dest.position.x - 12.0 and p_pos.x <= dest.end.x + 12.0 and
						 p_pos.y >= dest.position.y - 18.0 and p_pos.y <= dest.position.y + roof_h_px + 10.0)
		
		var tint := Color(1.0, 1.0, 1.0, 0.58) if is_behind else Color.WHITE
		draw_texture_rect_region(tex, Rect2(draw_pos, Vector2(draw_size.x, roof_h_px)), src, tint)

	func _draw_building_upper_overlay(b_rect: Rect2, base_tint: Color = Color.WHITE) -> void:
		if not is_instance_valid(map) or not is_instance_valid(map.tex_gedung):
			return
		var upper_h: float = b_rect.size.y * GEDUNG_UPPER_RATIO
		var src_h: float = 2031.0 * GEDUNG_UPPER_RATIO
		var src := Rect2(1620.0, 822.0, 951.0, src_h)
		var dest := Rect2(b_rect.position, Vector2(b_rect.size.x, upper_h))
		
		# Efek X-Ray Transparan saat pemain berada di belakang fasad gedung
		var is_behind := false
		if is_instance_valid(map) and is_instance_valid(map.player_cached):
			var p_pos: Vector2 = map.player_cached.global_position
			is_behind = (p_pos.x >= b_rect.position.x - 12.0 and p_pos.x <= b_rect.end.x + 12.0 and
						 p_pos.y >= b_rect.position.y - 20.0 and p_pos.y <= b_rect.position.y + upper_h + 10.0)
		
		var draw_tint := base_tint
		if is_behind:
			draw_tint.a = 0.58
		else:
			draw_tint.a = 1.0
			
		draw_texture_rect_region(map.tex_gedung, dest, src, draw_tint)

	func _draw() -> void:
		if not is_instance_valid(map):
			return

		# ── 1. Atap 11 Rumah Atas ──────────────────────────────────────────────
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

		# ── 3b. Atap 2 Rumah Blok NE ──────────────────────────────────────────
		var rne_sk = 1.0 if (map.rumah_ne_skala == null or map.rumah_ne_skala <= 0.0) else float(map.rumah_ne_skala)
		var rne_w = (map.rumah_ne_lebar if (map.rumah_ne_lebar != null and map.rumah_ne_lebar > 0.0) else 132.0) * rne_sk
		var rne_h = (map.rumah_ne_tinggi if (map.rumah_ne_tinggi != null and map.rumah_ne_tinggi > 0.0) else 116.0) * rne_sk
		var rne_gx = (map.rumah_ne_geser_x if map.rumah_ne_geser_x != null else 0.0)
		var rne_gy = (map.rumah_ne_geser_y if map.rumah_ne_geser_y != null else 0.0)
		for n_pos in map.get_ne_house_positions():
			_draw_house_roof(map.tex_rumah_depan, Rect2(n_pos.x + 12 + rne_gx, n_pos.y + 6 + rne_gy, rne_w, rne_h))

		# ── 4. Kanopi Peron Stasiun ───────────────────────────────────────────
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

		# ── 5. Atap Gedung-Gedung Blok NW ──
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
				_draw_building_upper_overlay(b_rect, tint)
				if map.gedung_nw_rooftop_props:
					map._draw_rooftop_props_to(self, b_rect, idx)

		# ── 5b. Gedung Benjolan Persegi NW ──
		if map.gedung_benjolan_tampilkan and is_instance_valid(map.tex_gedung):
			var bg_rect: Rect2 = map.get_benjolan_gedung_rect()
			_draw_building_upper_overlay(bg_rect, Color.WHITE)
			if map.gedung_nw_rooftop_props:
				map._draw_rooftop_props_to(self, bg_rect, 99)

		# ── Atap Kompleks Metropolitan World Trade Center ──────────────────────
		if map.wtc_tampilkan and is_instance_valid(map.tex_gedung):
			# 1. Barisan Gedung Finansial Utara (5 Gedung)
			var north_rects: Array[Rect2] = map.get_wtc_north_towers()
			for idx in range(north_rects.size()):
				var b_rect: Rect2 = north_rects[idx]
				_draw_building_upper_overlay(b_rect, Color.WHITE)
				map._draw_rooftop_props_to(self, b_rect, 10 + idx)

			# 2. Menara Kembar WTC (1 WTC & 2 WTC)
			var twin_rects: Array[Rect2] = map.get_wtc_twin_towers()
			if twin_rects.size() >= 2:
				var t1_rect: Rect2 = twin_rects[0]
				var t2_rect: Rect2 = twin_rects[1]
				_draw_building_upper_overlay(t1_rect, Color.WHITE)
				if map.wtc_spire_tampilkan:
					map._draw_wtc_spire_to(self, t1_rect)
				_draw_building_upper_overlay(t2_rect, Color.WHITE)
				map._draw_wtc_observation_deck_to(self, t2_rect)

			# 3. Gedung Sayap Selatan (3 WTC & 4 WTC)
			var flank_rects: Array[Rect2] = map.get_wtc_south_flank_towers()
			for idx in range(flank_rects.size()):
				var b_rect: Rect2 = flank_rects[idx]
				_draw_building_upper_overlay(b_rect, Color.WHITE)
				map._draw_rooftop_props_to(self, b_rect, 30 + idx)

		# ── 6. Atap Gedung Samping Rumah Sakit ──
		if map.gedung_rs_tampilkan and is_instance_valid(map.tex_gedung):
			var rs_rects: Array[Rect2] = map.get_rs_gedung_rects()
			for idx in range(rs_rects.size()):
				var b_rect: Rect2 = rs_rects[idx]
				_draw_building_upper_overlay(b_rect, Color.WHITE)
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

	# Gedung Utama Rumah Sakit: Bodi bangunan solid tanpa celah tembus
	var rs_gx = (rs_geser_x if rs_geser_x != null else 0.0)
	var rs_gy = (rs_geser_y if rs_geser_y != null else 0.0)
	_add_box_collider(sb, Rect2(755.0 + rs_gx, 966.0 + rs_gy, 128.0, 270.0)) # Menara Utama Timur
	_add_box_collider(sb, Rect2(696.0 + rs_gx, 1037.0 + rs_gy, 65.0, 168.0)) # Bangunan Penghubung
	_add_box_collider(sb, Rect2(623.0 + rs_gx, 1014.0 + rs_gy, 80.0, 222.0)) # Sayap Gawat Darurat Barat

	# Batang Pohon Taman Rumah Sakit Solid
	for t_pos in get_hospital_park_trees():
		_add_box_collider(sb, Rect2(t_pos.x - 7.0, t_pos.y - 7.0, 14.0, 14.0))

	# Gedung Stasiun Kereta
	var st_sk = 1.0 if (stasiun_skala == null or stasiun_skala <= 0.0) else float(stasiun_skala)
	_add_box_collider(sb, Rect2(1991 + (stasiun_geser_x if stasiun_geser_x != null else 0.0), 698 + (stasiun_geser_y if stasiun_geser_y != null else 0.0), 142 * st_sk, 245 * st_sk))

	# 2 Rumah Blok NE (Bodi Rumah Solid & Pagar Halaman Keliling)
	var ne_positions = get_ne_house_positions()
	for idx in range(ne_positions.size()):
		_add_fenced_house_colliders(sb, ne_positions[idx], "ne", "ne_%d" % idx)

	# 3. Rumah Warga (11 Rumah Atas) - Bodi Rumah Solid & Pagar Halaman Keliling
	for i in range(11):
		var sq_x = (13.0 + float(i) * 62.0) * 3.0
		var sq_y = 36.0
		_add_fenced_house_colliders(sb, Vector2(sq_x, sq_y), "atas", "top_%d" % i)

	# 3 Rumah Tenggara - Bodi Rumah Solid & Pagar Halaman Keliling
	var hy_list_colliders: Array[float] = [705.0, 880.0, 1055.0]
	for idx in range(3):
		_add_fenced_house_colliders(sb, Vector2(1636.0, hy_list_colliders[idx]), "se", "se_%d" % idx)

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

	# 7. Gedung-Gedung di Blok NW (Pembatas di Lantai/Footprint Dasar - Bebas Lewat di Belakang Gedung)
	if gedung_nw_tampilkan:
		for b in get_nw_gedung_rects():
			_add_building_footprint_collider(sb, b)

	# 7b. Gedung Benjolan Persegi NW (Pembatas di Lantai Dasar)
	if gedung_benjolan_tampilkan:
		_add_building_footprint_collider(sb, get_benjolan_gedung_rect())

	# 7c. Kolam Renang NW (Hanya air kolam yang memiliki kolisi solid agar pemain bisa jalan di dek)
	if gedung_nw_kolam_tampilkan:
		_add_box_collider(sb, get_nw_kolam_water_rect())

	# 7d. Kompleks Metropolitan World Trade Center (Pembatas di Lantai Dasar - Bebas Lewat di Belakang Gedung)
	if wtc_tampilkan:
		# Gedung Finansial Barisan Utara (5 Gedung)
		for b in get_wtc_north_towers():
			_add_building_footprint_collider(sb, b)
		# Menara Kembar WTC (1 WTC & 2 WTC)
		for b in get_wtc_twin_towers():
			_add_building_footprint_collider(sb, b)
		# Gedung Sayap Selatan (3 WTC & 4 WTC)
		for b in get_wtc_south_flank_towers():
			_add_building_footprint_collider(sb, b)
		# Kolam Refleksi Memorial WTC (Solid agar tidak bisa masuk ke air)
		if wtc_pool_tampilkan:
			_add_box_collider(sb, get_wtc_memorial_pool_rect())

	# 8. Gedung di Samping Rumah Sakit (Pembatas di Lantai Dasar)
	if gedung_rs_tampilkan:
		for b_rect in get_rs_gedung_rects():
			_add_building_footprint_collider(sb, b_rect)

func _add_bitmap_collider(body: StaticBody2D, tex: Texture2D, target_rect: Rect2, alpha_threshold: float = 0.25, epsilon: float = 4.0) -> void:
	if not is_instance_valid(tex):
		return

	# Khusus tex_gedung: Ditarik murni dari region GEDUNG_SRC_RECT (951 x 2031) agar 100% pixel-perfect dengan visual gedung
	if tex == tex_gedung or (tex.resource_path != "" and tex.resource_path.ends_with("gedung.png")):
		if _cached_gedung_polys.is_empty():
			var img: Image = tex.get_image()
			if img:
				var crop: Image = img.get_region(Rect2i(1620, 822, 951, 2031))
				var bitmap := BitMap.new()
				bitmap.create_from_image_alpha(crop, alpha_threshold)
				_cached_gedung_polys = bitmap.opaque_to_polygons(Rect2i(0, 0, 951, 2031), epsilon)
		for poly in _cached_gedung_polys:
			if poly.size() < 3:
				continue
			var scaled_poly := PackedVector2Array()
			scaled_poly.resize(poly.size())
			for pi in range(poly.size()):
				scaled_poly[pi] = Vector2(
					target_rect.position.x + (poly[pi].x / _cached_gedung_size.x) * target_rect.size.x,
					target_rect.position.y + (poly[pi].y / _cached_gedung_size.y) * target_rect.size.y
				)
			var col := CollisionPolygon2D.new()
			col.polygon = scaled_poly
			body.add_child(col)
		return

	# Khusus rumah warga (tex_rumah_depan / tex_rumah_mc): Di-cache sekali agar 11 rumah tidak mengulang komputasi
	if tex == tex_rumah_depan or tex == tex_rumah_mc or (tex.resource_path != "" and ("rumah" in tex.resource_path.to_lower())):
		if _cached_rumah_polys.is_empty():
			var img: Image = tex.get_image()
			if img:
				_cached_rumah_size = Vector2(img.get_width(), img.get_height())
				var bitmap := BitMap.new()
				bitmap.create_from_image_alpha(img, alpha_threshold)
				_cached_rumah_polys = bitmap.opaque_to_polygons(Rect2i(0, 0, img.get_width(), img.get_height()), epsilon)
		if not _cached_rumah_polys.is_empty() and _cached_rumah_size.x > 0 and _cached_rumah_size.y > 0:
			var scale_factor: float = min(target_rect.size.x / _cached_rumah_size.x, target_rect.size.y / _cached_rumah_size.y)
			var draw_size := _cached_rumah_size * scale_factor
			var draw_pos := target_rect.position + (target_rect.size - draw_size) * 0.5
			for poly in _cached_rumah_polys:
				if poly.size() < 3:
					continue
				var scaled_poly := PackedVector2Array()
				scaled_poly.resize(poly.size())
				for pi in range(poly.size()):
					scaled_poly[pi] = draw_pos + poly[pi] * scale_factor
				var col := CollisionPolygon2D.new()
				col.polygon = scaled_poly
				body.add_child(col)
			return

	# Khusus kantor polisi (tex_police): Di-cache sekali
	if tex == tex_police or (tex.resource_path != "" and ("police" in tex.resource_path.to_lower())):
		if _cached_police_polys.is_empty():
			var img: Image = tex.get_image()
			if img:
				_cached_police_size = Vector2(img.get_width(), img.get_height())
				var bitmap := BitMap.new()
				bitmap.create_from_image_alpha(img, alpha_threshold)
				_cached_police_polys = bitmap.opaque_to_polygons(Rect2i(0, 0, img.get_width(), img.get_height()), epsilon)
		if not _cached_police_polys.is_empty() and _cached_police_size.x > 0 and _cached_police_size.y > 0:
			var scale_factor: float = min(target_rect.size.x / _cached_police_size.x, target_rect.size.y / _cached_police_size.y)
			var draw_size := _cached_police_size * scale_factor
			var draw_pos := target_rect.position + (target_rect.size - draw_size) * 0.5
			for poly in _cached_police_polys:
				if poly.size() < 3:
					continue
				var scaled_poly := PackedVector2Array()
				scaled_poly.resize(poly.size())
				for pi in range(poly.size()):
					scaled_poly[pi] = draw_pos + poly[pi] * scale_factor
				var col := CollisionPolygon2D.new()
				col.polygon = scaled_poly
				body.add_child(col)
			return

	# Khusus rumah sakit (tex_hospital): Di-cache sekali
	if tex == tex_hospital or (tex.resource_path != "" and ("hospital" in tex.resource_path.to_lower())):
		if _cached_hospital_polys.is_empty():
			var img: Image = tex.get_image()
			if img:
				_cached_hospital_size = Vector2(img.get_width(), img.get_height())
				var bitmap := BitMap.new()
				bitmap.create_from_image_alpha(img, alpha_threshold)
				_cached_hospital_polys = bitmap.opaque_to_polygons(Rect2i(0, 0, img.get_width(), img.get_height()), epsilon)
		if not _cached_hospital_polys.is_empty() and _cached_hospital_size.x > 0 and _cached_hospital_size.y > 0:
			var scale_factor: float = min(target_rect.size.x / _cached_hospital_size.x, target_rect.size.y / _cached_hospital_size.y)
			var draw_size := _cached_hospital_size * scale_factor
			var draw_pos := target_rect.position + (target_rect.size - draw_size) * 0.5
			for poly in _cached_hospital_polys:
				if poly.size() < 3:
					continue
				var scaled_poly := PackedVector2Array()
				scaled_poly.resize(poly.size())
				for pi in range(poly.size()):
					scaled_poly[pi] = draw_pos + poly[pi] * scale_factor
				var col := CollisionPolygon2D.new()
				col.polygon = scaled_poly
				body.add_child(col)
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

func _add_building_footprint_collider(body: StaticBody2D, b_rect: Rect2, footprint_ratio: float = 0.32) -> void:
	if b_rect.size.x <= 0 or b_rect.size.y <= 0:
		return
	var fp_h: float = b_rect.size.y * footprint_ratio
	var fp_y: float = b_rect.position.y + b_rect.size.y * (1.0 - footprint_ratio)
	var fp_x: float = b_rect.position.x
	var fp_w: float = b_rect.size.x
	_add_box_collider(body, Rect2(fp_x, fp_y, fp_w, fp_h))

func _add_fenced_house_colliders(sb: StaticBody2D, pos: Vector2, house_type: String = "atas", gate_key: String = "") -> void:
	var sq_x: float = pos.x
	var sq_y: float = pos.y

	var h_sk: float = 1.0
	var h_gx: float = 0.0
	var h_gy: float = 0.0

	if house_type == "ne":
		h_sk = 1.0 if (rumah_ne_skala == null or rumah_ne_skala <= 0.0) else float(rumah_ne_skala)
		h_gx = (rumah_ne_geser_x if rumah_ne_geser_x != null else 0.0)
		h_gy = (rumah_ne_geser_y if rumah_ne_geser_y != null else 0.0)
	elif house_type == "se":
		h_sk = 1.0 if (rumah_se_skala == null or rumah_se_skala <= 0.0) else float(rumah_se_skala)
		h_gx = (rumah_se_geser_x if rumah_se_geser_x != null else 0.0)
		h_gy = (rumah_se_geser_y if rumah_se_geser_y != null else 0.0)
	else:
		h_sk = 1.0 if (rumah_atas_skala == null or rumah_atas_skala <= 0.0) else float(rumah_atas_skala)
		h_gx = (rumah_atas_geser_x if rumah_atas_geser_x != null else 0.0)
		h_gy = (rumah_atas_geser_y if rumah_atas_geser_y != null else 0.0)

	# 1. Bodi Inti Rumah (Dinding & Pondasi Solid - Lantai Dasar)
	# Pembatas ditaruh di lantainya (dinding dasar) bukan di atap gedung/rumah,
	# sehingga pemain bisa lewat leluasa di belakang rumah (halaman belakang).
	var wall_x = sq_x + 30.0 * h_sk + h_gx
	var wall_y = sq_y + 70.0 * h_sk + h_gy
	var wall_w = 98.0 * h_sk
	var wall_h = 44.0 * h_sk
	_add_box_collider(sb, Rect2(wall_x, wall_y, wall_w, wall_h))

	# 2. Pagar Belakang (North Fence) Solid
	var back_x = sq_x + (pagar_belakang_geser_x if pagar_belakang_geser_x != null else 0.0)
	var back_y = sq_y - 6.0 + (pagar_belakang_geser_y if pagar_belakang_geser_y != null else 0.0)
	_add_box_collider(sb, Rect2(back_x, back_y, 156.0, 16.0))

	# 3. Pagar Samping Kiri (West Fence) Solid
	var side_y = sq_y - 6.0 + (pagar_samping_geser_y if pagar_samping_geser_y != null else 0.0) + (gap_sudut_atas_samping if gap_sudut_atas_samping != null else 0.0)
	var side_w = (pagar_samping_lebar if (pagar_samping_lebar != null and pagar_samping_lebar > 0.0) else 12.0)
	var side_h = (pagar_samping_tinggi if (pagar_samping_tinggi != null and pagar_samping_tinggi > 0.0) else 148.0)
	var side_x_left = sq_x - 3.0 + (pagar_samping_kiri_geser_x if pagar_samping_kiri_geser_x != null else 0.0)
	_add_box_collider(sb, Rect2(side_x_left, side_y, side_w, side_h))

	# 4. Pagar Samping Kanan (East Fence) Solid
	var side_x_right = sq_x + 156.0 - side_w + 3.0 + (pagar_samping_kanan_geser_x if pagar_samping_kanan_geser_x != null else 0.0)
	_add_box_collider(sb, Rect2(side_x_right, side_y, side_w, side_h))

	# 5. Pagar Depan Kiri (South-West Fence) Solid
	var sk_kiri = 1.0 if (pagar_kiri_skala == null or pagar_kiri_skala <= 0.0) else float(pagar_kiri_skala)
	var front_l_x = sq_x + (pagar_kiri_geser_x if pagar_kiri_geser_x != null else 0.0)
	var front_l_y = sq_y + 130.0 + (pagar_kiri_geser_y if pagar_kiri_geser_y != null else 0.0)
	var max_l_w = max(30.0, (sq_x + 62.0) - front_l_x)
	var front_l_w = min((pagar_kiri_lebar if (pagar_kiri_lebar != null and pagar_kiri_lebar > 0.0) else 62.0) * sk_kiri, max_l_w)
	_add_box_collider(sb, Rect2(front_l_x, front_l_y, front_l_w, 20.0 * sk_kiri))

	# 6. Pagar Depan Kanan (South-East Fence) Solid
	var sk_kanan = 1.0 if (pagar_kanan_skala == null or pagar_kanan_skala <= 0.0) else float(pagar_kanan_skala)
	var front_r_x = sq_x + 92.0
	var front_r_y = sq_y + 130.0 + (pagar_kanan_geser_y if pagar_kanan_geser_y != null else 0.0)
	var front_r_w = max(20.0, (sq_x + 156.0) - front_r_x)
	_add_box_collider(sb, Rect2(front_r_x, front_r_y, front_r_w, 20.0 * sk_kanan))

	# 7. Pintu Pagar Dinamis (Menutup solid saat pemain jauh, membuka saat didekati)
	if gate_key != "":
		var gate_shape = CollisionShape2D.new()
		gate_shape.name = "GateCol_" + gate_key
		var box = RectangleShape2D.new()
		box.size = Vector2(30.0, 16.0)
		gate_shape.shape = box
		gate_shape.position = Vector2(sq_x + 77.0, sq_y + 138.0)
		sb.add_child(gate_shape)
		gate_colliders[gate_key] = gate_shape

func _load_textures() -> void:
	tex_hospital = load("res://Environment/Bangunan/Hospital.png")
	tex_police = load("res://Environment/Bangunan/police.png")
	tex_gedung = load("res://Environment/Bangunan/gedung.png")
	if tex_gedung != null and _cached_gedung_polys.is_empty():
		var img: Image = tex_gedung.get_image()
		if img:
			var crop: Image = img.get_region(Rect2i(1620, 822, 951, 2031))
			var bitmap := BitMap.new()
			bitmap.create_from_image_alpha(crop, 0.25)
			_cached_gedung_polys = bitmap.opaque_to_polygons(Rect2i(0, 0, 951, 2031), 4.0)
	tex_rumah_mc = load("res://Environment/Bangunan/rumahMC.png")
	tex_rumah_depan = load("res://Environment/Bangunan/rumahTampakDepan.png")
	if tex_rumah_depan != null and _cached_rumah_polys.is_empty():
		var img_r: Image = tex_rumah_depan.get_image()
		if img_r:
			_cached_rumah_size = Vector2(img_r.get_width(), img_r.get_height())
			var bitmap_r := BitMap.new()
			bitmap_r.create_from_image_alpha(img_r, 0.25)
			_cached_rumah_polys = bitmap_r.opaque_to_polygons(Rect2i(0, 0, img_r.get_width(), img_r.get_height()), 4.0)

	if tex_police != null and _cached_police_polys.is_empty():
		var img_p: Image = tex_police.get_image()
		if img_p:
			_cached_police_size = Vector2(img_p.get_width(), img_p.get_height())
			var bitmap_p := BitMap.new()
			bitmap_p.create_from_image_alpha(img_p, 0.25)
			_cached_police_polys = bitmap_p.opaque_to_polygons(Rect2i(0, 0, img_p.get_width(), img_p.get_height()), 4.0)

	if tex_hospital != null and _cached_hospital_polys.is_empty():
		var img_h: Image = tex_hospital.get_image()
		if img_h:
			_cached_hospital_size = Vector2(img_h.get_width(), img_h.get_height())
			var bitmap_h := BitMap.new()
			bitmap_h.create_from_image_alpha(img_h, 0.25)
			_cached_hospital_polys = bitmap_h.opaque_to_polygons(Rect2i(0, 0, img_h.get_width(), img_h.get_height()), 4.0)
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

	if ResourceLoader.exists("res://Environment/jalan/lurus.png"):
		tex_jalan_lurus = load("res://Environment/jalan/lurus.png")
	if ResourceLoader.exists("res://Environment/jalan/simpang3.png"):
		tex_jalan_simpang3 = load("res://Environment/jalan/simpang3.png")
	if ResourceLoader.exists("res://Environment/jalan/simpang4.png"):
		tex_jalan_simpang4 = load("res://Environment/jalan/simpang4.png")

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

	# Gedung-gedung Blok NW
	if gedung_nw_tampilkan:
		for b in get_nw_gedung_rects():
			nav_poly.add_outline(PackedVector2Array([
				b.position,
				Vector2(b.end.x, b.position.y),
				b.end,
				Vector2(b.position.x, b.end.y)
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
	
	# Gedung Kantor Polisi
	nav_poly.add_outline(PackedVector2Array([
		Vector2(10, 961), Vector2(347, 961), Vector2(347, 1301), Vector2(10, 1301)
	]))

	# Gedung Utama Rumah Sakit
	var r_sk_nav = 1.0 if (rs_skala == null or rs_skala <= 0.0) else float(rs_skala)
	var r_w_nav = (rs_lebar if (rs_lebar != null and rs_lebar > 0.0) else 585.0) * r_sk_nav
	var r_h_nav = (rs_tinggi if (rs_tinggi != null and rs_tinggi > 0.0) else 300.0) * r_sk_nav
	var hosp_r := Rect2(465 + (rs_geser_x if rs_geser_x != null else 0.0), 945 + (rs_geser_y if rs_geser_y != null else 0.0), r_w_nav, r_h_nav)
	nav_poly.add_outline(PackedVector2Array([
		hosp_r.position, Vector2(hosp_r.end.x, hosp_r.position.y),
		hosp_r.end, Vector2(hosp_r.position.x, hosp_r.end.y)
	]))
	
	# Kompleks Metropolitan World Trade Center (North Financial Skyscraper Row)
	if wtc_tampilkan:
		for b in get_wtc_north_towers():
			nav_poly.add_outline(PackedVector2Array([
				b.position, Vector2(b.end.x, b.position.y),
				b.end, Vector2(b.position.x, b.end.y)
			]))

	# Dua Rumah Blok NE (Hanya Bodi Bangunan)
	var rne_sk_nav = 1.0 if (rumah_ne_skala == null or rumah_ne_skala <= 0.0) else float(rumah_ne_skala)
	var rne_w_nav = (rumah_ne_lebar if (rumah_ne_lebar != null and rumah_ne_lebar > 0.0) else 132.0) * rne_sk_nav
	var rne_h_nav = (rumah_ne_tinggi if (rumah_ne_tinggi != null and rumah_ne_tinggi > 0.0) else 116.0) * rne_sk_nav
	var rne_gx_nav = (rumah_ne_geser_x if rumah_ne_geser_x != null else 0.0)
	var rne_gy_nav = (rumah_ne_geser_y if rumah_ne_geser_y != null else 0.0)
	for n_pos in get_ne_house_positions():
		var hr := Rect2(n_pos.x + 12 + rne_gx_nav, n_pos.y + 6 + rne_gy_nav, rne_w_nav, rne_h_nav)
		nav_poly.add_outline(PackedVector2Array([
			hr.position, Vector2(hr.end.x, hr.position.y),
			hr.end, Vector2(hr.position.x, hr.end.y)
		]))
	
	# Kompleks Metropolitan World Trade Center (Twin Towers, Flanking Towers, Memorial Pool)
	if wtc_tampilkan:
		for b in get_wtc_twin_towers():
			nav_poly.add_outline(PackedVector2Array([
				b.position, Vector2(b.end.x, b.position.y),
				b.end, Vector2(b.position.x, b.end.y)
			]))
		for b in get_wtc_south_flank_towers():
			nav_poly.add_outline(PackedVector2Array([
				b.position, Vector2(b.end.x, b.position.y),
				b.end, Vector2(b.position.x, b.end.y)
			]))
		if wtc_pool_tampilkan:
			var pool_r = get_wtc_memorial_pool_rect()
			nav_poly.add_outline(PackedVector2Array([
				pool_r.position, Vector2(pool_r.end.x, pool_r.position.y),
				pool_r.end, Vector2(pool_r.position.x, pool_r.end.y)
			]))

	# Gedung Samping Rumah Sakit
	if gedung_rs_tampilkan:
		for b in get_rs_gedung_rects():
			nav_poly.add_outline(PackedVector2Array([
				b.position, Vector2(b.end.x, b.position.y),
				b.end, Vector2(b.position.x, b.end.y)
			]))

	# Tiga Rumah Warga Tenggara (Hanya Bodi Bangunan)
	var rse_sk_nav = 1.0 if (rumah_se_skala == null or rumah_se_skala <= 0.0) else float(rumah_se_skala)
	var rse_w_nav = (rumah_se_lebar if (rumah_se_lebar != null and rumah_se_lebar > 0.0) else 132.0) * rse_sk_nav
	var rse_h_nav = (rumah_se_tinggi if (rumah_se_tinggi != null and rumah_se_tinggi > 0.0) else 116.0) * rse_sk_nav
	var rse_gx_nav = (rumah_se_geser_x if rumah_se_geser_x != null else 0.0)
	var rse_gy_nav = (rumah_se_geser_y if rumah_se_geser_y != null else 0.0)
	for hy in [705.0, 880.0, 1055.0]:
		var hr := Rect2(1636.0 + 12 + rse_gx_nav, hy + 6 + rse_gy_nav, rse_w_nav, rse_h_nav)
		nav_poly.add_outline(PackedVector2Array([
			hr.position, Vector2(hr.end.x, hr.position.y),
			hr.end, Vector2(hr.position.x, hr.end.y)
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
		Vector2(192, 786), Vector2(192, 951), Vector2(0, 951)
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

		# Jalur Setapak Batu (Stone Walkway Network) terintegrasi sejajar dan rapi
		var kw_rect := get_nw_kolam_water_rect()
		var p_color := Color(0.82, 0.80, 0.74)
		var p_border := Color(0.68, 0.66, 0.60)
		
		# 1. Promenade / Trotoar Utama di Depan Pintu Gedung Baris Depan
		draw_rect(Rect2(36, 678, 440, 16), p_color, true)
		draw_rect(Rect2(36, 678, 440, 16), p_border, false, 1.0)
		
		# 2. Akses ke Gerbang Timur (x=516) lurus dari Promenade
		draw_rect(Rect2(476, 678, 40, 16), p_color, true)
		draw_rect(Rect2(476, 678, 40, 16), p_border, false, 1.0)
		
		# 3. Akses ke Gerbang Selatan (x=360, y=786) di samping kolam
		draw_rect(Rect2(360, 760, 16, 26), p_color, true)
		draw_rect(Rect2(360, 760, 16, 26), p_border, false, 1.0)
		
		# 4. Akses ke Gedung Benjolan Persegi (x=70) lurus dari Promenade
		draw_rect(Rect2(70, 694, 16, 78), p_color, true)
		draw_rect(Rect2(70, 694, 16, 78), p_border, false, 1.0)
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

	#  Lapangan Hijau & Taman Asri Sekitar Rumah Sakit di Seluruh 1 Blok (y=690..1245, x=465..1050)
	_draw_hospital_park_grounds()
	
	# Dua Rumah Berpekarangan di Blok NE (1626,324)→(2016,549)
	var ne_positions = get_ne_house_positions()
	_draw_civilian_fenced_house(ne_positions[0], tex_rumah_depan, "ne_0", "ne")
	_draw_civilian_fenced_house(ne_positions[1], tex_rumah_depan, "ne_1", "ne")

	# Presisi Kantor Polisi
	_draw_room_pavement(Rect2(0, 951, 357, 360), COLOR_ROOM_STONE_B)

	# ── Jaringan Jalan Raya Kota (Digambar Di Atas Lantai & Tanah) ────────────
	_draw_city_road_network()

	# ── Stasiun Telepon Umum Kota (Jalan Raya) ──────────────────────────────────
	if telepon_jalan_tampilkan and is_instance_valid(tex_telepon):
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

	#  1. Gedung-Gedung Blok NW (North-West Complex) — proporsi asli, skala seragam
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

	#  1b. Gedung Benjolan Persegi NW (Menempati area benjolan x=0..192, y=786..933)
	if gedung_benjolan_tampilkan and is_instance_valid(tex_gedung):
		var bg_rect := get_benjolan_gedung_rect()
		if gedung_nw_depth_shadow:
			draw_rect(Rect2(bg_rect.position.x - 4, bg_rect.end.y - 4, bg_rect.size.x + 8, 8), Color(0, 0, 0, 0.25), true)
		draw_texture_rect_region(tex_gedung, bg_rect, GEDUNG_SRC_RECT, Color.WHITE)
		if gedung_nw_rooftop_props:
			_draw_rooftop_props_to(self, bg_rect, 99)

	#  Kolam Renang Mewah NW (Courtyard Pool)
	if gedung_nw_kolam_tampilkan:
		_draw_swimming_pool(get_nw_kolam_water_rect())

	# 2. Gedung samping RS (bot complex) (639,690)→(1050,1245) - Skala Seragam
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

	#  3. Kompleks Metropolitan World Trade Center (Twin Towers, Reflecting Pool, North Skyscraper Row)
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

	if poi_badge_tampilkan:
		_draw_poi_badge(Vector2(1200, 210), "Rumah Detektif Benedict", Color(0.95, 0.35, 0.30))
		_draw_poi_badge(Vector2(350, 258),  "Kantor Polisi",  Color(0.25, 0.50, 0.85))
		_draw_poi_badge(Vector2(2020, 960), "Stasiun Kereta", Color(0.95, 0.70, 0.20))
		_draw_poi_badge(Vector2(1270, 710), "World Trade Center", Color(0.20, 0.48, 0.78))
		_draw_poi_badge(Vector2(750, 1095), "Rumah Sakit",    Color(0.85, 0.25, 0.25))
		_draw_poi_badge(Vector2(180, 1050), "Brankas Ibu",    Color(0.80, 0.50, 0.90))

	# ── Lampu-Lampu Jalan Kota (Street Lamps) ──────────────────────────────────
	for l_pos in get_street_lamp_positions():
		_draw_street_lamp_post(l_pos)

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
	
	# Pintu Pagar Tengah (Membuka terdorong ke dalam halaman secara rotasi / swing)
	var open_ratio: float = gate_open_ratios.get(gate_key, 0.0)
	if open_ratio <= 0.0 and gate_slide_offsets.has(gate_key):
		open_ratio = clampf(abs(gate_slide_offsets[gate_key]) / 28.0, 0.0, 1.0)

	var gate_w = (pintu_pagar_lebar if (pintu_pagar_lebar != null and pintu_pagar_lebar > 0.0) else 32.0) * sk_pintu
	var gate_h = 30.0 * sk_pintu
	var gx = sq_x + 62.0 + (pintu_pagar_geser_x if pintu_pagar_geser_x != null else 0.0)
	var gy = sq_y + 126.0 + (pintu_pagar_geser_y if pintu_pagar_geser_y != null else 0.0)

	if open_ratio > 0.01:
		# Daun pintu pagar terdorong masuk ke dalam halaman (perspektif kedalaman):
		# Menyempit secara perspektif (foreshortening) ke arah engsel kiri dan mundur ke arah halaman
		var apparent_w: float = max(4.0, gate_w * (1.0 - open_ratio * 0.85))
		var recede_y: float = open_ratio * 10.0
		# Digambar murni tekstur pixel art asli tanpa garis bantu (draw_line) atau poligon buatan
		draw_texture_rect(tex_pintu_pagar, Rect2(gx, gy - recede_y, apparent_w, gate_h), false)
	else:
		# Pintu tertutup rapat melintang di jalan setapak
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


func get_hospital_park_trees() -> Array[Vector2]:
	return [
		# Bagian Utara Blok (Taman Asri & Area Bekas Gedung)
		Vector2(685.0, 735.0),
		Vector2(675.0, 830.0),
		Vector2(885.0, 735.0),
		Vector2(980.0, 740.0),
		Vector2(905.0, 845.0),
		Vector2(995.0, 855.0),
		Vector2(845.0, 905.0),
		Vector2(710.0, 915.0),
		# Bagian Selatan Blok (Taman Rindang Sekitar Rumah Sakit)
		Vector2(790.0, 990.0),
		Vector2(880.0, 1015.0),
		Vector2(980.0, 995.0),
		Vector2(810.0, 1130.0),
		Vector2(915.0, 1115.0),
		Vector2(1005.0, 1140.0),
		Vector2(855.0, 1205.0),
		Vector2(960.0, 1210.0),
		Vector2(735.0, 965.0),
		Vector2(500.0, 965.0),
	]

func _draw_hospital_park_tree(pos: Vector2, radius: float = 24.0) -> void:
	# Bayangan jatuh di atas rumput
	draw_circle(pos + Vector2(4.0, 6.0), radius + 2.0, Color(0.12, 0.20, 0.08, 0.35))
	# Batang pohon
	draw_circle(pos, 6.5, Color(0.32, 0.22, 0.14))
	draw_circle(pos, 4.0, Color(0.42, 0.30, 0.20))
	# Tajuk daun berlapis rimbun
	draw_circle(pos, radius, Color(0.18, 0.32, 0.12))
	draw_circle(pos + Vector2(-3.0, -3.0), radius * 0.80, Color(0.28, 0.46, 0.18))
	draw_circle(pos + Vector2(-6.0, -6.0), radius * 0.55, Color(0.38, 0.58, 0.22))
	draw_circle(pos + Vector2(-8.0, -8.0), radius * 0.30, Color(0.50, 0.70, 0.28))

func _draw_hospital_park_grounds() -> void:
	var rs_gx = (rs_geser_x if rs_geser_x != null else 0.0)
	var rs_gy = (rs_geser_y if rs_geser_y != null else 0.0)
	
	# 1. Rumput Hijau Lapangan Taman Segar & Rimbun di Seluruh 1 Blok Rumah Sakit
	var c_grass_base = Color(0.28, 0.44, 0.18)
	draw_rect(Rect2(639.0, 690.0, 411.0, 555.0), c_grass_base, true)
	draw_rect(Rect2(465.0, 951.0, 174.0, 294.0), c_grass_base, true)

	# Tekstur bercak rumput alami & bunga-bunga liar di seluruh blok
	for py in range(705, 1235, 32):
		var min_x = 650 if py < 951 else 480
		for px in range(min_x, 1035, 34):
			var hash_val = float((px * 47 + py * 89) % 19) - 9.0
			var col_blade = Color(0.22, 0.36, 0.14, 0.6) if int(px + py) % 2 == 0 else Color(0.35, 0.52, 0.22, 0.7)
			draw_line(Vector2(px + hash_val, py), Vector2(px + hash_val + 3.0, py - 5.0), col_blade, 1.5)
			draw_line(Vector2(px + hash_val + 3.0, py - 5.0), Vector2(px + hash_val + 6.0, py), col_blade, 1.5)
			if (px * 3 + py * 7) % 31 == 0:
				var f_col = Color(0.95, 0.85, 0.30, 0.8) if (px % 2 == 0) else Color(0.92, 0.45, 0.60, 0.8)
				draw_circle(Vector2(px + hash_val + 3.0, py - 6.0), 2.0, f_col)



	# 3. Jalur Setapak Pejalan Kaki (Walkways) di Seluruh Blok Taman
	var c_walkway = Color(0.78, 0.76, 0.72)
	var c_walkway_rim = Color(0.58, 0.56, 0.52)

	# Jalur Selatan (dari jalan selatan y=1245 ke pintu utama RS)
	draw_rect(Rect2(505.0, 1215.0, 32.0, 30.0), c_walkway, true)
	draw_rect(Rect2(505.0, 1215.0, 32.0, 30.0), c_walkway_rim, false, 1.2)
	# Jalur Promenade Timur ke Taman Selatan
	draw_rect(Rect2(735.0, 1075.0, 170.0, 24.0), c_walkway, true)
	draw_rect(Rect2(735.0, 1075.0, 170.0, 24.0), c_walkway_rim, false, 1.2)

	# Jalur Akses Masuk Utara dari Boulevard Tengah (y=690)
	draw_rect(Rect2(768.0, 690.0, 24.0, 95.0), c_walkway, true)
	draw_rect(Rect2(768.0, 690.0, 24.0, 95.0), c_walkway_rim, false, 1.2)

	# Jalur Penghubung Vertikal dari Bundaran Tengah Menuju Selatan / RS
	draw_rect(Rect2(768.0, 876.0, 24.0, 100.0), c_walkway, true)
	draw_rect(Rect2(768.0, 876.0, 24.0, 100.0), c_walkway_rim, false, 1.2)

	# Bundaran Plaza Taman Tengah & Gazebo Bunga (Di Sekitar NPC4 Boy)
	draw_circle(Vector2(780.0, 830.0), 48.0, c_walkway)
	draw_circle(Vector2(780.0, 830.0), 48.0, c_walkway_rim, false, 1.5)
	draw_circle(Vector2(780.0, 830.0), 36.0, c_grass_base)
	_draw_courtyard_garden(Vector2(780.0, 830.0), 32.0)

	# Jalur Cabang Timur Menuju Teras Santai Taman (Area Bekas Gedung)
	draw_rect(Rect2(828.0, 818.0, 120.0, 24.0), c_walkway, true)
	draw_rect(Rect2(828.0, 818.0, 120.0, 24.0), c_walkway_rim, false, 1.2)

	# Teras Santai Taman (Pavilion/Overlook di Area Bekas Gedung)
	var terrace_rect = Rect2(948.0, 804.0, 58.0, 52.0)
	draw_rect(terrace_rect, c_walkway, true)
	draw_rect(terrace_rect, c_walkway_rim, false, 1.5)
	_draw_tile_pattern(terrace_rect, Color(0.62, 0.60, 0.56, 0.45))

	# 4. Bangku-Bangku Taman di Seluruh 1 Blok
	# Bangku di Teras Santai Timur (bekas gedung)
	_draw_station_bench(Vector2(955.0, 792.0), 44.0, 14.0)
	_draw_station_bench(Vector2(955.0, 856.0), 44.0, 14.0)
	# Bangku di Dekat Bundaran Tengah
	_draw_station_bench(Vector2(716.0, 822.0), 36.0, 16.0)
	# Bangku di Bawah Rindang Pohon Utara
	_draw_station_bench(Vector2(845.0, 755.0), 36.0, 16.0)
	# Bangku di Promenade Selatan
	_draw_station_bench(Vector2(850.0, 1060.0), 36.0, 16.0)
	_draw_station_bench(Vector2(940.0, 1160.0), 36.0, 16.0)

	# 5. Pohon-Pohon Taman Rindang di Seluruh Blok
	for t_pos in get_hospital_park_trees():
		_draw_hospital_park_tree(t_pos, 22.0)

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
		Rect2(192,  786,   447, 165),  # Mid-West Plaza Road (x=192..639, y=786..951)
		Rect2(357,  951,   108, 360),  # SW Street Polisi-RS (x=357..465, y=951..1311)
		Rect2(516,  549,  1500, 141),  # Central Blvd        (x=516..2016, y=549..690)
		Rect2(1536, 192,    90, 1053), # East Vertical Avenue (x=1536..1626, y=192..1245)
		Rect2(2016, 192,   144, 498),  # Far-East Highway    (x=2016..2160, y=192..690)
		Rect2(0,    1245, 1860, 66),   # South Ring Road     (x=0..1860, y=1245..1311)
	]
	for r in asphalts:
		draw_rect(r, COLOR_ASPHALT, true)

	# ── 2. Garis Batas Tepi Jalan / Bahu Jalan (Curbs - Presisi & Menyatu) ───
	# North Boulevard (y = 194 tepi atas, y = 322 tepi bawah)
	draw_line(Vector2(0, 194), Vector2(2160, 194), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(0, 322), Vector2(518, 322), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(637, 322), Vector2(1538, 322), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1624, 322), Vector2(2018, 322), COLOR_CURB_LINE, 2.0)

	# West Vertical Road (x = 518 tepi barat, x = 637 tepi timur)
	draw_line(Vector2(518, 322), Vector2(518, 788), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(637, 322), Vector2(637, 551), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(637, 688), Vector2(637, 788), COLOR_CURB_LINE, 2.0)

	# Mid-West Plaza Road di Depan Kantor Polisi (y = 788..949, x = 194..637)
	draw_line(Vector2(194, 788), Vector2(518, 788), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(194, 788), Vector2(194, 949), COLOR_CURB_LINE, 2.0) # Batas barat plaza putar-balik
	draw_line(Vector2(194, 949), Vector2(359, 949), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(463, 949), Vector2(637, 949), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(637, 788), Vector2(637, 949), COLOR_CURB_LINE, 2.0) # Batas timur vs taman RS

	# South-West Street antara Kantor Polisi & RS (x = 359 tepi barat, x = 463 tepi timur)
	draw_line(Vector2(359, 949), Vector2(359, 1247), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(463, 949), Vector2(463, 1247), COLOR_CURB_LINE, 2.0)

	# Central Boulevard (y = 551 tepi utara, y = 688 tepi selatan)
	draw_line(Vector2(637, 551), Vector2(1538, 551), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1624, 551), Vector2(2018, 551), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(637, 688), Vector2(1538, 688), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1624, 688), Vector2(1792, 688), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1792, 688), Vector2(2018, 688), COLOR_CURB_LINE, 2.0)

	# East Vertical Avenue (x = 1538 tepi barat, x = 1624 tepi timur)
	draw_line(Vector2(1538, 322), Vector2(1538, 551), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1624, 322), Vector2(1624, 551), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1538, 688), Vector2(1538, 1247), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1624, 688), Vector2(1624, 1247), COLOR_CURB_LINE, 2.0)

	# Far-East Highway (x = 2018 tepi barat, x = 2158 tepi timur)
	draw_line(Vector2(2018, 322), Vector2(2018, 551), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(2158, 194), Vector2(2158, 688), COLOR_CURB_LINE, 2.0)

	# South Ring Road (y = 1247 tepi utara, y = 1309 tepi selatan)
	draw_line(Vector2(0, 1247), Vector2(359, 1247), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(463, 1247), Vector2(1538, 1247), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1624, 1247), Vector2(1860, 1247), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(0, 1309), Vector2(1860, 1309), COLOR_CURB_LINE, 2.0)
	draw_line(Vector2(1860, 1247), Vector2(1860, 1309), COLOR_CURB_LINE, 2.0) # Ujung timur jalan lingkar

	# ── 3. Penyeberangan Pejalan Kaki & Simpang 4 (Perempatan Sesuai simpang4.png) ────
	# [SIMPANG 4 RESMI] Perempatan Central Blvd x East Vertical Avenue
	# Sesuai pola simpang4.png: Kotak persimpangan bersih (aspal polos), dibingkai 4 Zebra Crossing di setiap lengan:
	var simpang4_box = Rect2(1536, 549, 90, 141)
	_draw_simpang4_perempatan(simpang4_box, 32.0)

	# Penyeberangan di Jalan Vertikal Barat (dekat North Blvd)
	_draw_road_zebra_crossing(Rect2(520, 334, 115, 32), false)
	# Penyeberangan di Avenue Vertikal Timur (dekat North Blvd)
	_draw_road_zebra_crossing(Rect2(1540, 334, 82, 32), false)
	# Penyeberangan di Jalan SW (antara Polisi & RS)
	_draw_road_zebra_crossing(Rect2(361, 960, 100, 32), false)

	# ── 4. Garis Putus-Putus Jalur Tengah & Simpang 3 (Pertigaan Sesuai simpang3.png) ─
	# Pola simpang3.png: Garis jalan utama tembus melintasi persimpangan,
	# dan garis jalan cabang bertemu tegak lurus membentuk sambungan huruf 'T' yang presisi.

	# --- [SIMPANG 3 #1] North Blvd x West Vertical (x = 577.5, y = 258.0) ---
	_draw_simpang3_junction(Vector2(577.5, 258.0), true, Vector2(0, 1), 22.0, COLOR_LANE_DASH, 2.0)

	# --- [SIMPANG 3 #2] North Blvd x East Vertical (x = 1581.0, y = 258.0) ---
	_draw_simpang3_junction(Vector2(1581.0, 258.0), true, Vector2(0, 1), 22.0, COLOR_LANE_DASH, 2.0)

	# --- [SIMPANG 3 #3] North Blvd x Far-East Highway (x = 2088.0, y = 258.0) ---
	_draw_simpang3_junction(Vector2(2088.0, 258.0), true, Vector2(0, 1), 22.0, COLOR_LANE_DASH, 2.0)

	# --- [SIMPANG 3 #4] West Vertical x Central Blvd (x = 577.5, y = 619.5) ---
	_draw_simpang3_junction(Vector2(577.5, 619.5), false, Vector2(1, 0), 22.0, COLOR_LANE_DASH, 2.0)

	# --- [SIMPANG 3 #5] Mid-West Plaza x SW Street (x = 411.0, y = 868.5) ---
	_draw_simpang3_junction(Vector2(411.0, 868.5), true, Vector2(0, 1), 22.0, COLOR_LANE_DASH, 2.0)

	# --- [SIMPANG 3 #6] South Ring Road x SW Street (x = 411.0, y = 1278.0) ---
	_draw_simpang3_junction(Vector2(411.0, 1278.0), true, Vector2(0, -1), 22.0, COLOR_LANE_DASH, 2.0)

	# --- [SIMPANG 3 #7] South Ring Road x East Vertical (x = 1581.0, y = 1278.0) ---
	_draw_simpang3_junction(Vector2(1581.0, 1278.0), true, Vector2(0, -1), 22.0, COLOR_LANE_DASH, 2.0)

	# ── Garis Putus-Putus Tiap Ruas Jalan (Menghubungkan Persimpangan Secara Mulus) ──
	# North Boulevard (y = 258.0)
	_draw_lane_dashes(Vector2(16, 258.0), Vector2(552.0, 258.0), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(602.0, 258.0), Vector2(1556.0, 258.0), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1606.0, 258.0), Vector2(2063.0, 258.0), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(2113.0, 258.0), Vector2(2140.0, 258.0), 22.0, 14.0, COLOR_LANE_DASH, 2.0)

	# West Vertical Road (x = 577.5)
	_draw_lane_dashes(Vector2(577.5, 294.0), Vector2(577.5, 330.0), 20.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)
	_draw_lane_dashes(Vector2(577.5, 376.0), Vector2(577.5, 594.0), 20.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)
	_draw_lane_dashes(Vector2(577.5, 644.0), Vector2(577.5, 775.0), 20.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)

	# Central Boulevard (y = 619.5 - Tidak menabrak zebra crossing WTC x=880..934 & x=1270..1324)
	_draw_lane_dashes(Vector2(613.0, 619.5), Vector2(862.0, 619.5), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(952.0, 619.5), Vector2(1252.0, 619.5), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1342.0, 619.5), Vector2(1484.0, 619.5), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(1676.0, 619.5), Vector2(1996.0, 619.5), 22.0, 14.0, COLOR_LANE_DASH, 2.0)

	# East Vertical Avenue (x = 1581.0)
	_draw_lane_dashes(Vector2(1581.0, 294.0), Vector2(1581.0, 330.0), 20.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)
	_draw_lane_dashes(Vector2(1581.0, 376.0), Vector2(1581.0, 500.0), 20.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)
	_draw_lane_dashes(Vector2(1581.0, 738.0), Vector2(1581.0, 1242.0), 20.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)

	# Far-East Highway (x = 2088.0)
	_draw_lane_dashes(Vector2(2088.0, 294.0), Vector2(2088.0, 532.0), 22.0, 14.0, COLOR_LANE_DASH, 2.0)

	# Mid-West Plaza Road di Depan Polisi (y = 868.5)
	_draw_lane_dashes(Vector2(212, 868.5), Vector2(386.0, 868.5), 22.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(435.0, 868.5), Vector2(622.0, 868.5), 22.0, 14.0, COLOR_LANE_DASH, 2.0)

	# South-West Street (x = 411.0 antara Polisi & RS)
	_draw_lane_dashes(Vector2(411.0, 904.0), Vector2(411.0, 955.0), 20.0, 14.0, COLOR_LANE_DASH, 2.0)
	_draw_lane_dashes(Vector2(411.0, 1004.0), Vector2(411.0, 1242.0), 20.0, 14.0, COLOR_LANE_DASH, 2.0)

	# South Ring Road (y = 1278.0)
	_draw_lane_dashes(Vector2(20, 1278.0), Vector2(386.0, 1278.0), 22.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)
	_draw_lane_dashes(Vector2(435.0, 1278.0), Vector2(1556.0, 1278.0), 22.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)
	_draw_lane_dashes(Vector2(1606.0, 1278.0), Vector2(1840.0, 1278.0), 22.0, 14.0, Color(COLOR_LANE_DASH.r, COLOR_LANE_DASH.g, COLOR_LANE_DASH.b, 0.75), 2.0)

	# ── 5. Garis Berhenti / Stop Bar Sebelum Penyeberangan & Persimpangan ─────
	# Garis henti sebelum Zebra Crossing 1 WTC (Central Blvd):
	_draw_stop_bar(Vector2(870, 619.5), Vector2(870, 686.0))
	_draw_stop_bar(Vector2(944, 553.0), Vector2(944, 619.5))

	# Garis henti sebelum Zebra Crossing 2 WTC (Central Blvd):
	_draw_stop_bar(Vector2(1260, 619.5), Vector2(1260, 686.0))
	_draw_stop_bar(Vector2(1334, 553.0), Vector2(1334, 619.5))

	# Garis henti Simpang 4 (Perempatan Central Blvd x East Vertical):
	# Lengan Utara (East Vertical dari utara, lajur kanan henti sebelum zebra):
	_draw_stop_bar(Vector2(1542.0, 508.0), Vector2(1581.0, 508.0))
	# Lengan Selatan (East Vertical dari selatan, lajur kanan henti sebelum zebra):
	_draw_stop_bar(Vector2(1581.0, 730.0), Vector2(1620.0, 730.0))
	# Lengan Barat (Central Blvd dari barat, lajur kanan/bawah henti sebelum zebra):
	_draw_stop_bar(Vector2(1492.0, 619.5), Vector2(1492.0, 686.0))
	# Lengan Timur (Central Blvd dari timur, lajur kanan/atas henti sebelum zebra):
	_draw_stop_bar(Vector2(1668.0, 553.0), Vector2(1668.0, 619.5))

	# Garis henti persimpangan lainnya:
	_draw_stop_bar(Vector2(577.5, 372.0), Vector2(633.0, 372.0))
	_draw_stop_bar(Vector2(1581.0, 372.0), Vector2(1620.0, 372.0))
	_draw_stop_bar(Vector2(645.0, 553.0), Vector2(645.0, 619.5))
	_draw_stop_bar(Vector2(411.0, 1238.0), Vector2(459.0, 1238.0))
	_draw_stop_bar(Vector2(1581.0, 1238.0), Vector2(1620.0, 1238.0))

func _draw_road_zebra_crossing(rect: Rect2, is_vertical: bool = false) -> void:
	# Strip kuning taktil penyeberangan di kedua sisi
	if is_vertical:
		draw_rect(Rect2(rect.position.x - 2, rect.position.y - 2, rect.size.x + 4, 4), Color(0.88, 0.74, 0.22), true)
		draw_rect(Rect2(rect.position.x - 2, rect.end.y - 2, rect.size.x + 4, 4), Color(0.88, 0.74, 0.22), true)
		for sy in range(int(rect.position.y) + 4, int(rect.end.y) - 6, 14):
			draw_rect(Rect2(rect.position.x, sy, rect.size.x, 8.0), Color(0.95, 0.95, 0.96, 0.90), true)
	else:
		draw_rect(Rect2(rect.position.x - 2, rect.position.y - 2, 4, rect.size.y + 4), Color(0.88, 0.74, 0.22), true)
		draw_rect(Rect2(rect.end.x - 2, rect.position.y - 2, 4, rect.size.y + 4), Color(0.88, 0.74, 0.22), true)
		for sx in range(int(rect.position.x) + 4, int(rect.end.x) - 6, 14):
			draw_rect(Rect2(sx, rect.position.y, 8.0, rect.size.y), Color(0.95, 0.95, 0.96, 0.90), true)

func _draw_lane_dashes(p1: Vector2, p2: Vector2, dash_len: float = 22.0, gap_len: float = 14.0, color: Color = COLOR_LANE_DASH, width: float = 2.0) -> void:
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
	draw_line(p1, p2, Color(1, 1, 1, 0.88), 3.0)

## Menggambar sambungan garis putus-putus Simpang 3 (Pertigaan) persis seperti simpang3.png:
## Garis jalan utama mengalir tembus melintasi persimpangan,
## dan garis jalan cabang bertemu tegak lurus membentuk sambungan huruf 'T' yang presisi di titik temu.
func _draw_simpang3_junction(center: Vector2, through_is_horizontal: bool, branch_dir: Vector2, dash_len: float = 22.0, color: Color = COLOR_LANE_DASH, width: float = 2.0) -> void:
	if through_is_horizontal:
		draw_line(Vector2(center.x - dash_len * 0.5, center.y), Vector2(center.x + dash_len * 0.5, center.y), color, width)
		var stem_end = center + branch_dir.normalized() * dash_len
		draw_line(center, stem_end, color, width)
	else:
		draw_line(Vector2(center.x, center.y - dash_len * 0.5), Vector2(center.x, center.y + dash_len * 0.5), color, width)
		var stem_end = center + branch_dir.normalized() * dash_len
		draw_line(center, stem_end, color, width)

## Menggambar persimpangan Simpang 4 (Perempatan) persis seperti simpang4.png:
## Area tengah persimpangan kotak aspal bersih tanpa garis marka,
## dan di keempat sisi jalan masuk (Utara, Selatan, Barat, Timur) dibingkai Zebra Crossing penyeberangan jalan.
func _draw_simpang4_perempatan(intersection_box: Rect2, arm_width: float = 32.0) -> void:
	# 1. Zebra crossing lengan Utara (pada jalan vertikal di atas kotak)
	_draw_road_zebra_crossing(Rect2(intersection_box.position.x + 2, intersection_box.position.y - arm_width - 4, intersection_box.size.x - 4, arm_width), false)
	# 2. Zebra crossing lengan Selatan (pada jalan vertikal di bawah kotak)
	_draw_road_zebra_crossing(Rect2(intersection_box.position.x + 2, intersection_box.end.y + 4, intersection_box.size.x - 4, arm_width), false)
	# 3. Zebra crossing lengan Barat (pada jalan horizontal di kiri kotak)
	_draw_road_zebra_crossing(Rect2(intersection_box.position.x - arm_width - 4, intersection_box.position.y + 2, arm_width, intersection_box.size.y - 4), true)
	# 4. Zebra crossing lengan Timur (pada jalan horizontal di kanan kotak)
	_draw_road_zebra_crossing(Rect2(intersection_box.end.x + 4, intersection_box.position.y + 2, arm_width, intersection_box.size.y - 4), true)

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

func get_street_lamp_positions() -> Array[Vector2]:
	var lamps: Array[Vector2] = []
	# 1. Boulevard Utara (y=192..324) - Trotoar Atas (depan pagar rumah warga)
	for lx in [90.0, 275.0, 460.0, 645.0, 830.0, 1015.0, 1200.0, 1385.0, 1570.0, 1755.0, 1940.0, 2110.0]:
		lamps.append(Vector2(lx, 184.0))
	# 1b. Boulevard Utara - Trotoar Bawah (depan taman/WTC/NW)
	for lx in [260.0, 480.0, 750.0, 1050.0, 1350.0, 1650.0, 1950.0]:
		lamps.append(Vector2(lx, 332.0))

	# 2. Boulevard Tengah (y=549..690)
	# Trotoar Utara
	for lx in [680.0, 920.0, 1160.0, 1400.0, 1640.0, 1880.0]:
		lamps.append(Vector2(lx, 542.0))
	# Trotoar Selatan
	for lx in [680.0, 920.0, 1160.0, 1400.0, 1640.0, 1880.0]:
		lamps.append(Vector2(lx, 698.0))

	# 3. Jalan Vertikal Barat (x=516..639)
	for ly in [390.0, 480.0, 740.0]:
		lamps.append(Vector2(510.0, ly))
		lamps.append(Vector2(644.0, ly))

	# 4. Jalan Vertikal Timur (x=1536..1626)
	for ly in [390.0, 480.0, 740.0, 900.0, 1060.0, 1210.0]:
		lamps.append(Vector2(1530.0, ly))
		lamps.append(Vector2(1632.0, ly))

	# 5. Area Depan Kantor Polisi & Jalan Barat Tengah
	lamps.append(Vector2(265.0, 942.0))
	lamps.append(Vector2(325.0, 942.0))
	lamps.append(Vector2(220.0, 782.0))
	lamps.append(Vector2(400.0, 782.0))

	# 6. Area Depan Rumah Sakit & Jalan Barat Daya
	lamps.append(Vector2(720.0, 940.0))
	lamps.append(Vector2(860.0, 940.0))
	lamps.append(Vector2(352.0, 1080.0))
	lamps.append(Vector2(470.0, 1080.0))
	lamps.append(Vector2(760.0, 785.0))
	lamps.append(Vector2(950.0, 775.0))

	# 7. Area Stasiun Kereta Api (Platform & Parkiran)
	for lx in [1890.0, 1990.0, 2090.0]:
		lamps.append(Vector2(lx, 686.0))
		lamps.append(Vector2(lx, 940.0))

	# 8. Esplanade Marmer World Trade Center
	for ly in [770.0, 960.0, 1150.0]:
		lamps.append(Vector2(1160.0, ly))
		lamps.append(Vector2(1376.0, ly))

	return lamps

func _draw_street_lamp_post(pos: Vector2) -> void:
	# 1. Bayangan jatuh alas tiang di atas trotoar
	draw_circle(pos + Vector2(2, 3), 3.5, Color(0, 0, 0, 0.20))
	# 2. Dudukan / Base tiang besi cor hitam
	draw_circle(pos, 3.5, Color(0.14, 0.16, 0.20))
	draw_circle(pos, 2.0, Color(0.24, 0.27, 0.32))
	# 3. Tiang utama vertikal
	draw_line(pos, pos + Vector2(0, -6), Color(0.20, 0.22, 0.26), 2.0)
	# 4. Lentera tudung lampu
	draw_rect(Rect2(pos.x - 3.0, pos.y - 7, 6.0, 3.0), Color(0.16, 0.18, 0.22), true)

	var ws = get_node_or_null("../WorldShader")
	var is_night = ws.is_night_mode if is_instance_valid(ws) and "is_night_mode" in ws else false
	if is_night:
		# 5. Bohlam kaca menyala lembut hangat di malam hari
		draw_circle(pos + Vector2(0, -4), 1.5, Color(1.0, 0.92, 0.72, 0.75))
		# 6. Halo visual lembut hangat
		draw_circle(pos, 7.0, Color(1.0, 0.85, 0.45, 0.05))
		draw_circle(pos, 3.5, Color(1.0, 0.90, 0.60, 0.10))
	else:
		# 5b. Bohlam mati di siang hari (kaca matte alami tanpa emisi)
		draw_circle(pos + Vector2(0, -4), 1.3, Color(0.70, 0.72, 0.75, 0.50))

func _setup_street_lights() -> void:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([
		Color(1.0, 0.88, 0.52, 0.45),
		Color(1.0, 0.78, 0.40, 0.22),
		Color(0.95, 0.65, 0.25, 0.06),
		Color(0.85, 0.50, 0.15, 0.0)
	])
	grad.offsets = PackedFloat32Array([0.0, 0.25, 0.65, 1.0])
	var light_tex := GradientTexture2D.new()
	light_tex.gradient = grad
	light_tex.fill = GradientTexture2D.FILL_RADIAL
	light_tex.fill_from = Vector2(0.5, 0.5)
	light_tex.fill_to = Vector2(1.0, 0.5)
	light_tex.width = 256
	light_tex.height = 256

	var ws = get_node_or_null("../WorldShader")
	var is_night = ws.is_night_mode if is_instance_valid(ws) and "is_night_mode" in ws else false

	street_lights.clear()
	var lamp_positions := get_street_lamp_positions()
	for pos in lamp_positions:
		var light := PointLight2D.new()
		light.name = "StreetLight"
		light.texture = light_tex
		light.texture_scale = street_lamp_scale
		light.energy = street_lamp_energy * randf_range(0.94, 1.06)
		light.color = Color(1.0, 0.88, 0.55, 1.0)
		light.position = pos
		light.enabled = is_night
		add_child(light)
		street_lights.append(light)

func set_street_lights_night_mode(is_night: bool) -> void:
	for light in street_lights:
		if is_instance_valid(light):
			light.enabled = is_night
	queue_redraw()
