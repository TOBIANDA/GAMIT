# 📝 GDSCRIPT STYLE GUIDE & BEST PRACTICES
## Standar Kode Resmi untuk Tim Game Godot 4.x

Panduan ini mengikuti pedoman resmi [Godot 4 GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) agar seluruh programmer tim menulis kode yang seragam, mudah dibaca, dan minim bug.

---

## 1. Konvensi Penamaan (Naming Conventions)

| Tipe Elemen | Konvensi | Contoh Benar | Contoh Salah |
|---|---|---|---|
| **Nama File** | `snake_case` | `morgue_inspection.gd` | `MorgueInspection.gd`, `morgue inspection.gd` |
| **Nama Kelas / Class** | `PascalCase` | `class_name InvestigationManager` | `class_name investigation_manager` |
| **Nama Node di Scene** | `PascalCase` | `Player`, `DialogBox`, `BGMPlayer` | `player_body`, `dialog-box` |
| **Fungsi / Method** | `snake_case` | `start_minigame()`, `open_morgue()` | `StartMinigame()`, `openMorgue()` |
| **Variabel Publik** | `snake_case` | `is_active`, `move_speed` | `isActive`, `MoveSpeed` |
| **Variabel / Fungsi Privat** | `_snake_case` | `_setup_audio()`, `_on_submit()` | `setupAudio()`, `onSubmit()` |
| **Konstanta** | `CONSTANT_CASE` | `MAX_STAMINA`, `SOAK_DURATION` | `maxStamina`, `Max_Stamina` |
| **Nama Enum** | `PascalCase` | `enum Phase`, `enum NPCType` | `enum phase`, `enum npc_type` |
| **Anggota Enum** | `CONSTANT_CASE` | `Phase.PROLOGUE_HOME` | `Phase.prologue_home` |
| **Sinyal (Signal)** | `past_tense_snake_case` | `signal safe_opened(success)`, `signal phase_changed` | `signal openSafe`, `signal PhaseChanged` |

---

## 2. Tipisasi Statis (Static Typing)

> [!IMPORTANT]
> **Selalu gunakan type annotation** pada deklarasi variabel, parameter fungsi, dan return type. Tipisasi statis meningkatkan performa GDScript hingga 30% dan mendeteksi bug sedini mungkin sebelum runtime.

```gdscript
# BENAR:
var player_speed: float = 140.0
var clue_count: int = 0
var current_title: String = "Prolog"

func calculate_distance(target_pos: Vector2) -> float:
	return global_position.distance_to(target_pos)

# HINDARI:
var player_speed = 140.0
func calculate_distance(target_pos):
	return global_position.distance_to(target_pos)
```

---

## 3. Urutan Struktur File Skrip (File Organization)

Setiap file `.gd` harus disusun dengan urutan standar berikut:

```gdscript
# 1. Deklarasi inheritance / kelas
extends Node2D
class_name GameManager

# 2. Sinyal
signal game_started
signal game_finished(score: int)

# 3. Enum
enum State { IDLE, RUNNING, PAUSED }

# 4. Konstanta
const DEFAULT_SPEED: float = 200.0

# 5. @export variables (terlihat di Inspector)
@export var show_intro: bool = true

# 6. Variabel Publik
var current_state: State = State.IDLE

# 7. Variabel Privat (dimulai dengan underscore)
var _timer: float = 0.0

# 8. @onready variables
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

# 9. Fungsi bawaan mesin (Engine Lifecycle Methods)
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	pass

# 10. Fungsi Publik
func start_new_game() -> void:
	pass

# 11. Fungsi Privat & Helper
func _setup_scene() -> void:
	pass

# 12. Callback Sinyal
func _on_player_died() -> void:
	pass
```

---

## 4. Keamanan Referensi Node & Assertions

1. **Gunakan `@onready` secara aman**:
   ```gdscript
   @onready var sprite: Sprite2D = $Sprite2D
   ```
2. **Periksa validitas objek sebelum diakses**:
   ```gdscript
   if is_instance_valid(player) and player.can_move:
       player.velocity = Vector2.ZERO
   ```
3. **Gunakan assertions saat inisialisasi modul**:
   ```gdscript
   assert(ResourceLoader.exists("res://sound/BGM.mp3"), "File BGM.mp3 tidak ditemukan!")
   ```
