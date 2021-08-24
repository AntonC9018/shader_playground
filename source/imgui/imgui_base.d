module imgui.imgui_base;

import core.stdc.errno;
import core.stdc.string;
import core.stdc.stddef;
import core.stdc.stdarg;
import core.stdc.float_;

import core.stdc.config;
import std.bitmanip : bitfields;
import std.conv : emplace;

bool isModuleAvailable(alias T)() {
    mixin("import " ~ T ~ ";");
    static if (__traits(compiles, (mixin(T)).stringof))
        return true;
    else
        return false;
}
    
static if (__traits(compiles, isModuleAvailable!"nsgen" )) 
    static import nsgen;

struct CppClassSizeAttr
{
    alias size this;
    size_t size;
}
CppClassSizeAttr cppclasssize(size_t a) { return CppClassSizeAttr(a); }

struct CppSizeAttr
{
    alias size this;
    size_t size;
}
CppSizeAttr cppsize(size_t a) { return CppSizeAttr(a); }

struct CppMethodAttr{}
CppMethodAttr cppmethod() { return CppMethodAttr(); }

struct PyExtract{}
auto pyExtract(string name = null) { return PyExtract(); }

mixin template RvalueRef()
{
    alias T = typeof(this);
    static assert (is(T == struct));

    @nogc @safe
    ref const(T) byRef() const pure nothrow return
    {
        return this;
    }
}


enum IMGUI_VERSION = "1.83";
enum IMGUI_VERSION_NUM = 18300;
enum IMGUI_CHECKVERSION = `ImGui::DebugCheckVersionAndDataLayout(IMGUI_VERSION,sizeof(ImGuiIO),sizeof(ImGuiStyle),sizeof(ImVec2),sizeof(ImVec4),sizeof(ImDrawVert),sizeof(ImDrawIdx))`;
enum IMGUI_IMPL_API = `IMGUI_API`;
enum IM_ASSERT(_EXPR) = `assert_(_EXPR)`;
enum IM_ARRAYSIZE(_ARR) = `((int)(sizeof(_ARR)/sizeof(*(_ARR))))`;
enum IM_UNUSED(_VAR) = `((void)(_VAR))`;
enum IM_OFFSETOF(_TYPE, _MEMBER) = `offsetof(_TYPE,_MEMBER)`;
enum IM_FMTARGS(FMT) = `__attribute((format(printf,FMT,FMT+1)))`;
enum IM_FMTLIST(FMT) = `__attribute((format(printf,FMT,0)))`;
enum IMGUI_PAYLOAD_TYPE_COLOR_3F = "_COL3F";
enum IMGUI_PAYLOAD_TYPE_COLOR_4F = "_COL4F";
enum IM_ALLOC(_SIZE) = `ImGui::MemAlloc(_SIZE)`;
enum IM_FREE(_PTR) = `ImGui::MemFree(_PTR)`;
enum IM_PLACEMENT_NEW(_PTR) = `new(ImNewWrapper(),_PTR)`;
enum IM_NEW(_TYPE) = `new(ImNewWrapper(),ImGui::MemAlloc(sizeof(_TYPE)))_TYPE`;
enum IM_UNICODE_CODEPOINT_INVALID = 0xFFFD;
enum IM_UNICODE_CODEPOINT_MAX = 0xFFFF;
enum IM_COL32_R_SHIFT = 0;
enum IM_COL32_G_SHIFT = 8;
enum IM_COL32_B_SHIFT = 16;
enum IM_COL32_A_SHIFT = 24;
enum IM_COL32_A_MASK = 0xFF000000;
enum IM_COL32(R, G, B, A) = `(((ImU32)(A)<<IM_COL32_A_SHIFT)|((ImU32)(B)<<IM_COL32_B_SHIFT)|((ImU32)(G)<<IM_COL32_G_SHIFT)|((ImU32)(R)<<IM_COL32_R_SHIFT))`;
enum IM_COL32_WHITE = `IM_COL32(255,255,255,255)`;
enum IM_COL32_BLACK = `IM_COL32(0,0,0,255)`;
enum IM_COL32_BLACK_TRANS = `IM_COL32(0,0,0,0)`;
enum IM_DRAWLIST_TEX_LINES_WIDTH_MAX = (63);
enum ImDrawCallback_ResetRenderState = `(ImDrawCallback)(-1)`;
alias ImGuiCol = int;

alias ImGuiCond = int;

alias ImGuiDataType = int;

alias ImGuiDir = int;

alias ImGuiKey = int;

alias ImGuiNavInput = int;

alias ImGuiMouseButton = int;

alias ImGuiMouseCursor = int;

alias ImGuiSortDirection = int;

alias ImGuiStyleVar = int;

alias ImGuiTableBgTarget = int;

alias ImDrawFlags = int;

alias ImDrawListFlags = int;

alias ImFontAtlasFlags = int;

alias ImGuiBackendFlags = int;

alias ImGuiButtonFlags = int;

alias ImGuiColorEditFlags = int;

alias ImGuiConfigFlags = int;

alias ImGuiComboFlags = int;

alias ImGuiDragDropFlags = int;

alias ImGuiFocusedFlags = int;

alias ImGuiHoveredFlags = int;

alias ImGuiInputTextFlags = int;

alias ImGuiKeyModFlags = int;

alias ImGuiPopupFlags = int;

alias ImGuiSelectableFlags = int;

alias ImGuiSliderFlags = int;

alias ImGuiTabBarFlags = int;

alias ImGuiTabItemFlags = int;

alias ImGuiTableFlags = int;

alias ImGuiTableColumnFlags = int;

alias ImGuiTableRowFlags = int;

alias ImGuiTreeNodeFlags = int;

alias ImGuiViewportFlags = int;

alias ImGuiWindowFlags = int;

alias ImTextureID = void*;

alias ImGuiID = uint;

alias ImGuiInputTextCallback = extern(C++) int function(ImGuiInputTextCallbackData*);

alias ImGuiSizeCallback = extern(C++) void function(ImGuiSizeCallbackData*);

alias ImGuiMemAllocFunc = extern(C++) void* function(size_t, void*);

alias ImGuiMemFreeFunc = extern(C++) void function(void*, void*);

alias ImWchar16 = ushort;

alias ImWchar32 = uint;

alias ImWchar = ImWchar16;

alias ImS8 = char;

alias ImU8 = ubyte;

alias ImS16 = short;

alias ImU16 = ushort;

alias ImS32 = int;

alias ImU32 = uint;

alias ImS64 = long;

alias ImU64 = ulong;

extern(C++)
@cppclasssize(8) align(4)
struct ImVec2
{
    mixin RvalueRef;

    @cppsize(4) public float x;
    @cppsize(4) public float y;
    // /* inline */ public this()//{
    //x = y = 0f;
    //}

    public final void _default_ctor() {
    x = y = 0f;
    }

    /* inline */ public this(float _x, float _y){
    x = _x;
    y = _y;
    }

    /* inline */ public float opIndex(size_t idx) const {
    assert(!!(idx <= 1), "idx <= 1");
    return (&x)[idx];
    }

    /* inline */ public ref float opIndex(size_t idx){
    assert(!!(idx <= 1), "idx <= 1");
    return (&x)[idx];
    }

}
extern(C++)
@cppclasssize(16) align(4)
struct ImVec4
{
    mixin RvalueRef;

    @cppsize(4) public float x;
    @cppsize(4) public float y;
    @cppsize(4) public float z;
    @cppsize(4) public float w;
    // /* inline */ public this()//{
    //x = y = z = w = 0f;
    //}

    public final void _default_ctor() {
    x = y = z = w = 0f;
    }

    /* inline */ public this(float _x, float _y, float _z, float _w){
    x = _x;
    y = _y;
    z = _z;
    w = _w;
    }

}
extern(C++, "ImGui")
ImGuiContext* CreateContext(ImFontAtlas* shared_font_atlas = null);

extern(C++, "ImGui")
void DestroyContext(ImGuiContext* ctx = null);

extern(C++, "ImGui")
ImGuiContext* GetCurrentContext();

extern(C++, "ImGui")
void SetCurrentContext(ImGuiContext* ctx);

extern(C++, "ImGui")
ref ImGuiIO GetIO();

extern(C++, "ImGui")
ref ImGuiStyle GetStyle();

extern(C++, "ImGui")
void NewFrame();

extern(C++, "ImGui")
void EndFrame();

extern(C++, "ImGui")
void Render();

extern(C++, "ImGui")
ImDrawData* GetDrawData();

extern(C++, "ImGui")
void ShowDemoWindow(bool* p_open = null);

extern(C++, "ImGui")
void ShowMetricsWindow(bool* p_open = null);

extern(C++, "ImGui")
void ShowAboutWindow(bool* p_open = null);

extern(C++, "ImGui")
void ShowStyleEditor(ImGuiStyle* ref_ = null);

extern(C++, "ImGui")
bool ShowStyleSelector(const(char)* label);

extern(C++, "ImGui")
void ShowFontSelector(const(char)* label);

extern(C++, "ImGui")
void ShowUserGuide();

extern(C++, "ImGui")
const(char)* GetVersion();

extern(C++, "ImGui")
void StyleColorsDark(ImGuiStyle* dst = null);

extern(C++, "ImGui")
void StyleColorsLight(ImGuiStyle* dst = null);

extern(C++, "ImGui")
void StyleColorsClassic(ImGuiStyle* dst = null);

extern(C++, "ImGui")
bool Begin(const(char)* name, bool* p_open = null, ImGuiWindowFlags flags = 0);

extern(C++, "ImGui")
void End();

extern(C++, "ImGui")
bool BeginChild(const(char)* str_id, ref const(ImVec2) size = ImVec2(0, 0).byRef , bool border = false, ImGuiWindowFlags flags = 0);

extern(C++, "ImGui")
bool BeginChild(ImGuiID id, ref const(ImVec2) size = ImVec2(0, 0).byRef , bool border = false, ImGuiWindowFlags flags = 0);

extern(C++, "ImGui")
void EndChild();

extern(C++, "ImGui")
bool IsWindowAppearing();

extern(C++, "ImGui")
bool IsWindowCollapsed();

extern(C++, "ImGui")
bool IsWindowFocused(ImGuiFocusedFlags flags = 0);

extern(C++, "ImGui")
bool IsWindowHovered(ImGuiHoveredFlags flags = 0);

extern(C++, "ImGui")
ImDrawList* GetWindowDrawList();

extern(C++, "ImGui")
ImVec2 GetWindowPos();

extern(C++, "ImGui")
ImVec2 GetWindowSize();

extern(C++, "ImGui")
float GetWindowWidth();

extern(C++, "ImGui")
float GetWindowHeight();

extern(C++, "ImGui")
void SetNextWindowPos(ref const(ImVec2) pos, ImGuiCond cond = 0, ref const(ImVec2) pivot = ImVec2(0, 0).byRef );

extern(C++, "ImGui")
void SetNextWindowSize(ref const(ImVec2) size, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetNextWindowSizeConstraints(ref const(ImVec2) size_min, ref const(ImVec2) size_max, void function(ImGuiSizeCallbackData*) custom_callback = null, void* custom_callback_data = null);

extern(C++, "ImGui")
void SetNextWindowContentSize(ref const(ImVec2) size);

extern(C++, "ImGui")
void SetNextWindowCollapsed(bool collapsed, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetNextWindowFocus();

extern(C++, "ImGui")
void SetNextWindowBgAlpha(float alpha);

extern(C++, "ImGui")
void SetWindowPos(ref const(ImVec2) pos, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetWindowSize(ref const(ImVec2) size, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetWindowCollapsed(bool collapsed, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetWindowFocus();

extern(C++, "ImGui")
void SetWindowFontScale(float scale);

extern(C++, "ImGui")
void SetWindowPos(const(char)* name, ref const(ImVec2) pos, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetWindowSize(const(char)* name, ref const(ImVec2) size, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetWindowCollapsed(const(char)* name, bool collapsed, ImGuiCond cond = 0);

extern(C++, "ImGui")
void SetWindowFocus(const(char)* name);

extern(C++, "ImGui")
ImVec2 GetContentRegionAvail();

extern(C++, "ImGui")
ImVec2 GetContentRegionMax();

extern(C++, "ImGui")
ImVec2 GetWindowContentRegionMin();

extern(C++, "ImGui")
ImVec2 GetWindowContentRegionMax();

extern(C++, "ImGui")
float GetWindowContentRegionWidth();

extern(C++, "ImGui")
float GetScrollX();

extern(C++, "ImGui")
float GetScrollY();

extern(C++, "ImGui")
void SetScrollX(float scroll_x);

extern(C++, "ImGui")
void SetScrollY(float scroll_y);

extern(C++, "ImGui")
float GetScrollMaxX();

extern(C++, "ImGui")
float GetScrollMaxY();

extern(C++, "ImGui")
void SetScrollHereX(float center_x_ratio = 0.5f);

extern(C++, "ImGui")
void SetScrollHereY(float center_y_ratio = 0.5f);

extern(C++, "ImGui")
void SetScrollFromPosX(float local_x, float center_x_ratio = 0.5f);

extern(C++, "ImGui")
void SetScrollFromPosY(float local_y, float center_y_ratio = 0.5f);

extern(C++, "ImGui")
void PushFont(ImFont* font);

extern(C++, "ImGui")
void PopFont();

extern(C++, "ImGui")
void PushStyleColor(ImGuiCol idx, ImU32 col);

extern(C++, "ImGui")
void PushStyleColor(ImGuiCol idx, ref const(ImVec4) col);

extern(C++, "ImGui")
void PopStyleColor(int count = 1);

extern(C++, "ImGui")
void PushStyleVar(ImGuiStyleVar idx, float val);

extern(C++, "ImGui")
void PushStyleVar(ImGuiStyleVar idx, ref const(ImVec2) val);

extern(C++, "ImGui")
void PopStyleVar(int count = 1);

extern(C++, "ImGui")
void PushAllowKeyboardFocus(bool allow_keyboard_focus);

extern(C++, "ImGui")
void PopAllowKeyboardFocus();

extern(C++, "ImGui")
void PushButtonRepeat(bool repeat);

extern(C++, "ImGui")
void PopButtonRepeat();

extern(C++, "ImGui")
void PushItemWidth(float item_width);

extern(C++, "ImGui")
void PopItemWidth();

extern(C++, "ImGui")
void SetNextItemWidth(float item_width);

extern(C++, "ImGui")
float CalcItemWidth();

extern(C++, "ImGui")
void PushTextWrapPos(float wrap_local_pos_x = 0f);

extern(C++, "ImGui")
void PopTextWrapPos();

extern(C++, "ImGui")
ImFont* GetFont();

extern(C++, "ImGui")
float GetFontSize();

extern(C++, "ImGui")
ImVec2 GetFontTexUvWhitePixel();

extern(C++, "ImGui")
ImU32 GetColorU32(ImGuiCol idx, float alpha_mul = 1f);

extern(C++, "ImGui")
ImU32 GetColorU32(ref const(ImVec4) col);

extern(C++, "ImGui")
ImU32 GetColorU32(ImU32 col);

extern(C++, "ImGui")
ref const(ImVec4) GetStyleColorVec4(ImGuiCol idx);

extern(C++, "ImGui")
void Separator();

extern(C++, "ImGui")
void SameLine(float offset_from_start_x = 0f, float spacing = -1f);

extern(C++, "ImGui")
void NewLine();

extern(C++, "ImGui")
void Spacing();

extern(C++, "ImGui")
void Dummy(ref const(ImVec2) size);

extern(C++, "ImGui")
void Indent(float indent_w = 0f);

extern(C++, "ImGui")
void Unindent(float indent_w = 0f);

extern(C++, "ImGui")
void BeginGroup();

extern(C++, "ImGui")
void EndGroup();

extern(C++, "ImGui")
ImVec2 GetCursorPos();

extern(C++, "ImGui")
float GetCursorPosX();

extern(C++, "ImGui")
float GetCursorPosY();

extern(C++, "ImGui")
void SetCursorPos(ref const(ImVec2) local_pos);

extern(C++, "ImGui")
void SetCursorPosX(float local_x);

extern(C++, "ImGui")
void SetCursorPosY(float local_y);

extern(C++, "ImGui")
ImVec2 GetCursorStartPos();

extern(C++, "ImGui")
ImVec2 GetCursorScreenPos();

extern(C++, "ImGui")
void SetCursorScreenPos(ref const(ImVec2) pos);

extern(C++, "ImGui")
void AlignTextToFramePadding();

extern(C++, "ImGui")
float GetTextLineHeight();

extern(C++, "ImGui")
float GetTextLineHeightWithSpacing();

extern(C++, "ImGui")
float GetFrameHeight();

extern(C++, "ImGui")
float GetFrameHeightWithSpacing();

extern(C++, "ImGui")
void PushID(const(char)* str_id);

extern(C++, "ImGui")
void PushID(const(char)* str_id_begin, const(char)* str_id_end);

extern(C++, "ImGui")
void PushID(const(void)* ptr_id);

extern(C++, "ImGui")
void PushID(int int_id);

extern(C++, "ImGui")
void PopID();

extern(C++, "ImGui")
ImGuiID GetID(const(char)* str_id);

extern(C++, "ImGui")
ImGuiID GetID(const(char)* str_id_begin, const(char)* str_id_end);

extern(C++, "ImGui")
ImGuiID GetID(const(void)* ptr_id);

extern(C++, "ImGui")
void TextUnformatted(const(char)* text, const(char)* text_end = null);

extern(C++, "ImGui")
void Text(const(char)* fmt, ...);

extern(C++, "ImGui")
void TextV(const(char)* fmt, char* args);

extern(C++, "ImGui")
void TextColored(ref const(ImVec4) col, const(char)* fmt, ...);

extern(C++, "ImGui")
void TextColoredV(ref const(ImVec4) col, const(char)* fmt, char* args);

extern(C++, "ImGui")
void TextDisabled(const(char)* fmt, ...);

extern(C++, "ImGui")
void TextDisabledV(const(char)* fmt, char* args);

extern(C++, "ImGui")
void TextWrapped(const(char)* fmt, ...);

extern(C++, "ImGui")
void TextWrappedV(const(char)* fmt, char* args);

extern(C++, "ImGui")
void LabelText(const(char)* label, const(char)* fmt, ...);

extern(C++, "ImGui")
void LabelTextV(const(char)* label, const(char)* fmt, char* args);

extern(C++, "ImGui")
void BulletText(const(char)* fmt, ...);

extern(C++, "ImGui")
void BulletTextV(const(char)* fmt, char* args);

extern(C++, "ImGui")
bool Button(const(char)* label, ref const(ImVec2) size = ImVec2(0, 0).byRef );

extern(C++, "ImGui")
bool SmallButton(const(char)* label);

extern(C++, "ImGui")
bool InvisibleButton(const(char)* str_id, ref const(ImVec2) size, ImGuiButtonFlags flags = 0);

extern(C++, "ImGui")
bool ArrowButton(const(char)* str_id, ImGuiDir dir);

extern(C++, "ImGui")
void Image(void* user_texture_id, ref const(ImVec2) size, ref const(ImVec2) uv0 = ImVec2(0, 0).byRef , ref const(ImVec2) uv1 = ImVec2(1, 1).byRef , ref const(ImVec4) tint_col = ImVec4(1, 1, 1, 1).byRef , ref const(ImVec4) border_col = ImVec4(0, 0, 0, 0).byRef );

extern(C++, "ImGui")
bool ImageButton(void* user_texture_id, ref const(ImVec2) size, ref const(ImVec2) uv0 = ImVec2(0, 0).byRef , ref const(ImVec2) uv1 = ImVec2(1, 1).byRef , int frame_padding = -1, ref const(ImVec4) bg_col = ImVec4(0, 0, 0, 0).byRef , ref const(ImVec4) tint_col = ImVec4(1, 1, 1, 1).byRef );

extern(C++, "ImGui")
bool Checkbox(const(char)* label, bool* v);

extern(C++, "ImGui")
bool CheckboxFlags(const(char)* label, int* flags, int flags_value);

extern(C++, "ImGui")
bool CheckboxFlags(const(char)* label, uint* flags, uint flags_value);

extern(C++, "ImGui")
bool RadioButton(const(char)* label, bool active);

extern(C++, "ImGui")
bool RadioButton(const(char)* label, int* v, int v_button);

extern(C++, "ImGui")
void ProgressBar(float fraction, ref const(ImVec2) size_arg = ImVec2(-1.17549435E-38f, 0).byRef , const(char)* overlay = null);

extern(C++, "ImGui")
void Bullet();

extern(C++, "ImGui")
bool BeginCombo(const(char)* label, const(char)* preview_value, ImGuiComboFlags flags = 0);

extern(C++, "ImGui")
void EndCombo();

extern(C++, "ImGui")
bool Combo(const(char)* label, int* current_item, const(const(char))** items, int items_count, int popup_max_height_in_items = -1);

extern(C++, "ImGui")
bool Combo(const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items = -1);

extern(C++, "ImGui")
bool Combo(const(char)* label, int* current_item, bool function(void*, int, const(char)**) items_getter, void* data, int items_count, int popup_max_height_in_items = -1);

extern(C++, "ImGui")
bool DragFloat(const(char)* label, float* v, float v_speed = 1f, float v_min = 0f, float v_max = 0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragFloat2(const(char)* label, float* v, float v_speed = 1f, float v_min = 0f, float v_max = 0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragFloat3(const(char)* label, float* v, float v_speed = 1f, float v_min = 0f, float v_max = 0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragFloat4(const(char)* label, float* v, float v_speed = 1f, float v_min = 0f, float v_max = 0f, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragFloatRange2(const(char)* label, float* v_current_min, float* v_current_max, float v_speed = 1f, float v_min = 0f, float v_max = 0f, const(char)* format = "%.3f", const(char)* format_max = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragInt(const(char)* label, int* v, float v_speed = 1f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragInt2(const(char)* label, int* v, float v_speed = 1f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragInt3(const(char)* label, int* v, float v_speed = 1f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragInt4(const(char)* label, int* v, float v_speed = 1f, int v_min = 0, int v_max = 0, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragIntRange2(const(char)* label, int* v_current_min, int* v_current_max, float v_speed = 1f, int v_min = 0, int v_max = 0, const(char)* format = "%d", const(char)* format_max = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragScalar(const(char)* label, ImGuiDataType data_type, void* p_data, float v_speed = 1f, const(void)* p_min = null, const(void)* p_max = null, const(char)* format = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool DragScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed = 1f, const(void)* p_min = null, const(void)* p_max = null, const(char)* format = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderFloat(const(char)* label, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderFloat2(const(char)* label, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderFloat3(const(char)* label, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderFloat4(const(char)* label, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderAngle(const(char)* label, float* v_rad, float v_degrees_min = -360f, float v_degrees_max = +360f, const(char)* format = "%.0f deg", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderInt(const(char)* label, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderInt2(const(char)* label, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderInt3(const(char)* label, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderInt4(const(char)* label, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool SliderScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_min, const(void)* p_max, const(char)* format = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool VSliderFloat(const(char)* label, ref const(ImVec2) size, float* v, float v_min, float v_max, const(char)* format = "%.3f", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool VSliderInt(const(char)* label, ref const(ImVec2) size, int* v, int v_min, int v_max, const(char)* format = "%d", ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool VSliderScalar(const(char)* label, ref const(ImVec2) size, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format = null, ImGuiSliderFlags flags = 0);

extern(C++, "ImGui")
bool InputText(const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags = 0, int function(ImGuiInputTextCallbackData*) callback = null, void* user_data = null);

extern(C++, "ImGui")
bool InputTextMultiline(const(char)* label, char* buf, size_t buf_size, ref const(ImVec2) size = ImVec2(0, 0).byRef , ImGuiInputTextFlags flags = 0, int function(ImGuiInputTextCallbackData*) callback = null, void* user_data = null);

extern(C++, "ImGui")
bool InputTextWithHint(const(char)* label, const(char)* hint, char* buf, size_t buf_size, ImGuiInputTextFlags flags = 0, int function(ImGuiInputTextCallbackData*) callback = null, void* user_data = null);

extern(C++, "ImGui")
bool InputFloat(const(char)* label, float* v, float step = 0f, float step_fast = 0f, const(char)* format = "%.3f", ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputFloat2(const(char)* label, float* v, const(char)* format = "%.3f", ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputFloat3(const(char)* label, float* v, const(char)* format = "%.3f", ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputFloat4(const(char)* label, float* v, const(char)* format = "%.3f", ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputInt(const(char)* label, int* v, int step = 1, int step_fast = 100, ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputInt2(const(char)* label, int* v, ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputInt3(const(char)* label, int* v, ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputInt4(const(char)* label, int* v, ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputDouble(const(char)* label, double* v, double step = 0, double step_fast = 0, const(char)* format = "%.6f", ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_step = null, const(void)* p_step_fast = null, const(char)* format = null, ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool InputScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_step = null, const(void)* p_step_fast = null, const(char)* format = null, ImGuiInputTextFlags flags = 0);

extern(C++, "ImGui")
bool ColorEdit3(const(char)* label, float* col, ImGuiColorEditFlags flags = 0);

extern(C++, "ImGui")
bool ColorEdit4(const(char)* label, float* col, ImGuiColorEditFlags flags = 0);

extern(C++, "ImGui")
bool ColorPicker3(const(char)* label, float* col, ImGuiColorEditFlags flags = 0);

extern(C++, "ImGui")
bool ColorPicker4(const(char)* label, float* col, ImGuiColorEditFlags flags = 0, const(float)* ref_col = null);

extern(C++, "ImGui")
bool ColorButton(const(char)* desc_id, ref const(ImVec4) col, ImGuiColorEditFlags flags = 0, ImVec2 size = ImVec2(0, 0));

extern(C++, "ImGui")
void SetColorEditOptions(ImGuiColorEditFlags flags);

extern(C++, "ImGui")
bool TreeNode(const(char)* label);

extern(C++, "ImGui")
bool TreeNode(const(char)* str_id, const(char)* fmt, ...);

extern(C++, "ImGui")
bool TreeNode(const(void)* ptr_id, const(char)* fmt, ...);

extern(C++, "ImGui")
bool TreeNodeV(const(char)* str_id, const(char)* fmt, char* args);

extern(C++, "ImGui")
bool TreeNodeV(const(void)* ptr_id, const(char)* fmt, char* args);

extern(C++, "ImGui")
bool TreeNodeEx(const(char)* label, ImGuiTreeNodeFlags flags = 0);

extern(C++, "ImGui")
bool TreeNodeEx(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...);

extern(C++, "ImGui")
bool TreeNodeEx(const(void)* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...);

extern(C++, "ImGui")
bool TreeNodeExV(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, char* args);

extern(C++, "ImGui")
bool TreeNodeExV(const(void)* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, char* args);

extern(C++, "ImGui")
void TreePush(const(char)* str_id);

extern(C++, "ImGui")
void TreePush(const(void)* ptr_id = null);

extern(C++, "ImGui")
void TreePop();

extern(C++, "ImGui")
float GetTreeNodeToLabelSpacing();

extern(C++, "ImGui")
bool CollapsingHeader(const(char)* label, ImGuiTreeNodeFlags flags = 0);

extern(C++, "ImGui")
bool CollapsingHeader(const(char)* label, bool* p_visible, ImGuiTreeNodeFlags flags = 0);

extern(C++, "ImGui")
void SetNextItemOpen(bool is_open, ImGuiCond cond = 0);

extern(C++, "ImGui")
bool Selectable(const(char)* label, bool selected = false, ImGuiSelectableFlags flags = 0, ref const(ImVec2) size = ImVec2(0, 0).byRef );

extern(C++, "ImGui")
bool Selectable(const(char)* label, bool* p_selected, ImGuiSelectableFlags flags = 0, ref const(ImVec2) size = ImVec2(0, 0).byRef );

extern(C++, "ImGui")
bool BeginListBox(const(char)* label, ref const(ImVec2) size = ImVec2(0, 0).byRef );

extern(C++, "ImGui")
void EndListBox();

extern(C++, "ImGui")
bool ListBox(const(char)* label, int* current_item, const(const(char))** items, int items_count, int height_in_items = -1);

extern(C++, "ImGui")
bool ListBox(const(char)* label, int* current_item, bool function(void*, int, const(char)**) items_getter, void* data, int items_count, int height_in_items = -1);

extern(C++, "ImGui")
void PlotLines(const(char)* label, const(float)* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = 3.40282347E+38f, float scale_max = 3.40282347E+38f, ImVec2 graph_size = ImVec2(0, 0), int stride = (float).sizeof);

extern(C++, "ImGui")
void PlotLines(const(char)* label, float function(void*, int) values_getter, void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = 3.40282347E+38f, float scale_max = 3.40282347E+38f, ImVec2 graph_size = ImVec2(0, 0));

extern(C++, "ImGui")
void PlotHistogram(const(char)* label, const(float)* values, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = 3.40282347E+38f, float scale_max = 3.40282347E+38f, ImVec2 graph_size = ImVec2(0, 0), int stride = (float).sizeof);

extern(C++, "ImGui")
void PlotHistogram(const(char)* label, float function(void*, int) values_getter, void* data, int values_count, int values_offset = 0, const(char)* overlay_text = null, float scale_min = 3.40282347E+38f, float scale_max = 3.40282347E+38f, ImVec2 graph_size = ImVec2(0, 0));

extern(C++, "ImGui")
void Value(const(char)* prefix, bool b);

extern(C++, "ImGui")
void Value(const(char)* prefix, int v);

extern(C++, "ImGui")
void Value(const(char)* prefix, uint v);

extern(C++, "ImGui")
void Value(const(char)* prefix, float v, const(char)* float_format = null);

extern(C++, "ImGui")
bool BeginMenuBar();

extern(C++, "ImGui")
void EndMenuBar();

extern(C++, "ImGui")
bool BeginMainMenuBar();

extern(C++, "ImGui")
void EndMainMenuBar();

extern(C++, "ImGui")
bool BeginMenu(const(char)* label, bool enabled = true);

extern(C++, "ImGui")
void EndMenu();

extern(C++, "ImGui")
bool MenuItem(const(char)* label, const(char)* shortcut = null, bool selected = false, bool enabled = true);

extern(C++, "ImGui")
bool MenuItem(const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled = true);

extern(C++, "ImGui")
void BeginTooltip();

extern(C++, "ImGui")
void EndTooltip();

extern(C++, "ImGui")
void SetTooltip(const(char)* fmt, ...);

extern(C++, "ImGui")
void SetTooltipV(const(char)* fmt, char* args);

extern(C++, "ImGui")
bool BeginPopup(const(char)* str_id, ImGuiWindowFlags flags = 0);

extern(C++, "ImGui")
bool BeginPopupModal(const(char)* name, bool* p_open = null, ImGuiWindowFlags flags = 0);

extern(C++, "ImGui")
void EndPopup();

extern(C++, "ImGui")
void OpenPopup(const(char)* str_id, ImGuiPopupFlags popup_flags = 0);

extern(C++, "ImGui")
void OpenPopup(ImGuiID id, ImGuiPopupFlags popup_flags = 0);

extern(C++, "ImGui")
void OpenPopupOnItemClick(const(char)* str_id = null, ImGuiPopupFlags popup_flags = 1);

extern(C++, "ImGui")
void CloseCurrentPopup();

extern(C++, "ImGui")
bool BeginPopupContextItem(const(char)* str_id = null, ImGuiPopupFlags popup_flags = 1);

extern(C++, "ImGui")
bool BeginPopupContextWindow(const(char)* str_id = null, ImGuiPopupFlags popup_flags = 1);

extern(C++, "ImGui")
bool BeginPopupContextVoid(const(char)* str_id = null, ImGuiPopupFlags popup_flags = 1);

extern(C++, "ImGui")
bool IsPopupOpen(const(char)* str_id, ImGuiPopupFlags flags = 0);

extern(C++, "ImGui")
bool BeginTable(const(char)* str_id, int column, ImGuiTableFlags flags = 0, ref const(ImVec2) outer_size = ImVec2(0f, 0f).byRef , float inner_width = 0f);

extern(C++, "ImGui")
void EndTable();

extern(C++, "ImGui")
void TableNextRow(ImGuiTableRowFlags row_flags = 0, float min_row_height = 0f);

extern(C++, "ImGui")
bool TableNextColumn();

extern(C++, "ImGui")
bool TableSetColumnIndex(int column_n);

extern(C++, "ImGui")
void TableSetupColumn(const(char)* label, ImGuiTableColumnFlags flags = 0, float init_width_or_weight = 0f, ImGuiID user_id = 0);

extern(C++, "ImGui")
void TableSetupScrollFreeze(int cols, int rows);

extern(C++, "ImGui")
void TableHeadersRow();

extern(C++, "ImGui")
void TableHeader(const(char)* label);

extern(C++, "ImGui")
ImGuiTableSortSpecs* TableGetSortSpecs();

extern(C++, "ImGui")
int TableGetColumnCount();

extern(C++, "ImGui")
int TableGetColumnIndex();

extern(C++, "ImGui")
int TableGetRowIndex();

extern(C++, "ImGui")
const(char)* TableGetColumnName(int column_n = -1);

extern(C++, "ImGui")
ImGuiTableColumnFlags TableGetColumnFlags(int column_n = -1);

extern(C++, "ImGui")
void TableSetColumnEnabled(int column_n, bool v);

extern(C++, "ImGui")
void TableSetBgColor(ImGuiTableBgTarget target, ImU32 color, int column_n = -1);

extern(C++, "ImGui")
void Columns(int count = 1, const(char)* id = null, bool border = true);

extern(C++, "ImGui")
void NextColumn();

extern(C++, "ImGui")
int GetColumnIndex();

extern(C++, "ImGui")
float GetColumnWidth(int column_index = -1);

extern(C++, "ImGui")
void SetColumnWidth(int column_index, float width);

extern(C++, "ImGui")
float GetColumnOffset(int column_index = -1);

extern(C++, "ImGui")
void SetColumnOffset(int column_index, float offset_x);

extern(C++, "ImGui")
int GetColumnsCount();

extern(C++, "ImGui")
bool BeginTabBar(const(char)* str_id, ImGuiTabBarFlags flags = 0);

extern(C++, "ImGui")
void EndTabBar();

extern(C++, "ImGui")
bool BeginTabItem(const(char)* label, bool* p_open = null, ImGuiTabItemFlags flags = 0);

extern(C++, "ImGui")
void EndTabItem();

extern(C++, "ImGui")
bool TabItemButton(const(char)* label, ImGuiTabItemFlags flags = 0);

extern(C++, "ImGui")
void SetTabItemClosed(const(char)* tab_or_docked_window_label);

extern(C++, "ImGui")
void LogToTTY(int auto_open_depth = -1);

extern(C++, "ImGui")
void LogToFile(int auto_open_depth = -1, const(char)* filename = null);

extern(C++, "ImGui")
void LogToClipboard(int auto_open_depth = -1);

extern(C++, "ImGui")
void LogFinish();

extern(C++, "ImGui")
void LogButtons();

extern(C++, "ImGui")
void LogText(const(char)* fmt, ...);

extern(C++, "ImGui")
void LogTextV(const(char)* fmt, char* args);

extern(C++, "ImGui")
bool BeginDragDropSource(ImGuiDragDropFlags flags = 0);

extern(C++, "ImGui")
bool SetDragDropPayload(const(char)* type, const(void)* data, size_t sz, ImGuiCond cond = 0);

extern(C++, "ImGui")
void EndDragDropSource();

extern(C++, "ImGui")
bool BeginDragDropTarget();

extern(C++, "ImGui")
const(ImGuiPayload)* AcceptDragDropPayload(const(char)* type, ImGuiDragDropFlags flags = 0);

extern(C++, "ImGui")
void EndDragDropTarget();

extern(C++, "ImGui")
const(ImGuiPayload)* GetDragDropPayload();

extern(C++, "ImGui")
void PushClipRect(ref const(ImVec2) clip_rect_min, ref const(ImVec2) clip_rect_max, bool intersect_with_current_clip_rect);

extern(C++, "ImGui")
void PopClipRect();

extern(C++, "ImGui")
void SetItemDefaultFocus();

extern(C++, "ImGui")
void SetKeyboardFocusHere(int offset = 0);

extern(C++, "ImGui")
bool IsItemHovered(ImGuiHoveredFlags flags = 0);

extern(C++, "ImGui")
bool IsItemActive();

extern(C++, "ImGui")
bool IsItemFocused();

extern(C++, "ImGui")
bool IsItemClicked(ImGuiMouseButton mouse_button = 0);

extern(C++, "ImGui")
bool IsItemVisible();

extern(C++, "ImGui")
bool IsItemEdited();

extern(C++, "ImGui")
bool IsItemActivated();

extern(C++, "ImGui")
bool IsItemDeactivated();

extern(C++, "ImGui")
bool IsItemDeactivatedAfterEdit();

extern(C++, "ImGui")
bool IsItemToggledOpen();

extern(C++, "ImGui")
bool IsAnyItemHovered();

extern(C++, "ImGui")
bool IsAnyItemActive();

extern(C++, "ImGui")
bool IsAnyItemFocused();

extern(C++, "ImGui")
ImVec2 GetItemRectMin();

extern(C++, "ImGui")
ImVec2 GetItemRectMax();

extern(C++, "ImGui")
ImVec2 GetItemRectSize();

extern(C++, "ImGui")
void SetItemAllowOverlap();

extern(C++, "ImGui")
ImGuiViewport* GetMainViewport();

extern(C++, "ImGui")
bool IsRectVisible(ref const(ImVec2) size);

extern(C++, "ImGui")
bool IsRectVisible(ref const(ImVec2) rect_min, ref const(ImVec2) rect_max);

extern(C++, "ImGui")
double GetTime();

extern(C++, "ImGui")
int GetFrameCount();

extern(C++, "ImGui")
ImDrawList* GetBackgroundDrawList();

extern(C++, "ImGui")
ImDrawList* GetForegroundDrawList();

extern(C++, "ImGui")
ImDrawListSharedData* GetDrawListSharedData();

extern(C++, "ImGui")
const(char)* GetStyleColorName(ImGuiCol idx);

extern(C++, "ImGui")
void SetStateStorage(ImGuiStorage* storage);

extern(C++, "ImGui")
ImGuiStorage* GetStateStorage();

extern(C++, "ImGui")
void CalcListClipping(int items_count, float items_height, int* out_items_display_start, int* out_items_display_end);

extern(C++, "ImGui")
bool BeginChildFrame(ImGuiID id, ref const(ImVec2) size, ImGuiWindowFlags flags = 0);

extern(C++, "ImGui")
void EndChildFrame();

extern(C++, "ImGui")
ImVec2 CalcTextSize(const(char)* text, const(char)* text_end = null, bool hide_text_after_double_hash = false, float wrap_width = -1f);

extern(C++, "ImGui")
ImVec4 ColorConvertU32ToFloat4(ImU32 in_);

extern(C++, "ImGui")
ImU32 ColorConvertFloat4ToU32(ref const(ImVec4) in_);

extern(C++, "ImGui")
void ColorConvertRGBtoHSV(float r, float g, float b, ref float out_h, ref float out_s, ref float out_v);

extern(C++, "ImGui")
void ColorConvertHSVtoRGB(float h, float s, float v, ref float out_r, ref float out_g, ref float out_b);

extern(C++, "ImGui")
int GetKeyIndex(ImGuiKey imgui_key);

extern(C++, "ImGui")
bool IsKeyDown(int user_key_index);

extern(C++, "ImGui")
bool IsKeyPressed(int user_key_index, bool repeat = true);

extern(C++, "ImGui")
bool IsKeyReleased(int user_key_index);

extern(C++, "ImGui")
int GetKeyPressedAmount(int key_index, float repeat_delay, float rate);

extern(C++, "ImGui")
void CaptureKeyboardFromApp(bool want_capture_keyboard_value = true);

extern(C++, "ImGui")
bool IsMouseDown(ImGuiMouseButton button);

extern(C++, "ImGui")
bool IsMouseClicked(ImGuiMouseButton button, bool repeat = false);

extern(C++, "ImGui")
bool IsMouseReleased(ImGuiMouseButton button);

extern(C++, "ImGui")
bool IsMouseDoubleClicked(ImGuiMouseButton button);

extern(C++, "ImGui")
bool IsMouseHoveringRect(ref const(ImVec2) r_min, ref const(ImVec2) r_max, bool clip = true);

extern(C++, "ImGui")
bool IsMousePosValid(const(ImVec2)* mouse_pos = null);

extern(C++, "ImGui")
bool IsAnyMouseDown();

extern(C++, "ImGui")
ImVec2 GetMousePos();

extern(C++, "ImGui")
ImVec2 GetMousePosOnOpeningCurrentPopup();

extern(C++, "ImGui")
bool IsMouseDragging(ImGuiMouseButton button, float lock_threshold = -1f);

extern(C++, "ImGui")
ImVec2 GetMouseDragDelta(ImGuiMouseButton button = 0, float lock_threshold = -1f);

extern(C++, "ImGui")
void ResetMouseDragDelta(ImGuiMouseButton button = 0);

extern(C++, "ImGui")
ImGuiMouseCursor GetMouseCursor();

extern(C++, "ImGui")
void SetMouseCursor(ImGuiMouseCursor cursor_type);

extern(C++, "ImGui")
void CaptureMouseFromApp(bool want_capture_mouse_value = true);

extern(C++, "ImGui")
const(char)* GetClipboardText();

extern(C++, "ImGui")
void SetClipboardText(const(char)* text);

extern(C++, "ImGui")
void LoadIniSettingsFromDisk(const(char)* ini_filename);

extern(C++, "ImGui")
void LoadIniSettingsFromMemory(const(char)* ini_data, size_t ini_size = 0);

extern(C++, "ImGui")
void SaveIniSettingsToDisk(const(char)* ini_filename);

extern(C++, "ImGui")
const(char)* SaveIniSettingsToMemory(size_t* out_ini_size = null);

extern(C++, "ImGui")
bool DebugCheckVersionAndDataLayout(const(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx);

extern(C++, "ImGui")
void SetAllocatorFunctions(void* function(size_t, void*) alloc_func, void function(void*, void*) free_func, void* user_data = null);

extern(C++, "ImGui")
void GetAllocatorFunctions(void* function(size_t, void*)** p_alloc_func, void function(void*, void*)** p_free_func, void** p_user_data);

extern(C++, "ImGui")
void* MemAlloc(size_t size);

extern(C++, "ImGui")
void MemFree(void* ptr);

enum ImGuiWindowFlags_
{
    ImGuiWindowFlags_None = 0, 
    ImGuiWindowFlags_NoTitleBar = 1, 
    ImGuiWindowFlags_NoResize = 2, 
    ImGuiWindowFlags_NoMove = 4, 
    ImGuiWindowFlags_NoScrollbar = 8, 
    ImGuiWindowFlags_NoScrollWithMouse = 16, 
    ImGuiWindowFlags_NoCollapse = 32, 
    ImGuiWindowFlags_AlwaysAutoResize = 64, 
    ImGuiWindowFlags_NoBackground = 128, 
    ImGuiWindowFlags_NoSavedSettings = 256, 
    ImGuiWindowFlags_NoMouseInputs = 512, 
    ImGuiWindowFlags_MenuBar = 1024, 
    ImGuiWindowFlags_HorizontalScrollbar = 2048, 
    ImGuiWindowFlags_NoFocusOnAppearing = 4096, 
    ImGuiWindowFlags_NoBringToFrontOnFocus = 8192, 
    ImGuiWindowFlags_AlwaysVerticalScrollbar = 16384, 
    ImGuiWindowFlags_AlwaysHorizontalScrollbar = 32768, 
    ImGuiWindowFlags_AlwaysUseWindowPadding = 65536, 
    ImGuiWindowFlags_NoNavInputs = 262144, 
    ImGuiWindowFlags_NoNavFocus = 524288, 
    ImGuiWindowFlags_UnsavedDocument = 1048576, 
    ImGuiWindowFlags_NoNav = 786432, 
    ImGuiWindowFlags_NoDecoration = 43, 
    ImGuiWindowFlags_NoInputs = 786944, 
    ImGuiWindowFlags_NavFlattened = 8388608, 
    ImGuiWindowFlags_ChildWindow = 16777216, 
    ImGuiWindowFlags_Tooltip = 33554432, 
    ImGuiWindowFlags_Popup = 67108864, 
    ImGuiWindowFlags_Modal = 134217728, 
    ImGuiWindowFlags_ChildMenu = 268435456, 
}

alias ImGuiWindowFlags_None = ImGuiWindowFlags_.ImGuiWindowFlags_None;
alias ImGuiWindowFlags_NoTitleBar = ImGuiWindowFlags_.ImGuiWindowFlags_NoTitleBar;
alias ImGuiWindowFlags_NoResize = ImGuiWindowFlags_.ImGuiWindowFlags_NoResize;
alias ImGuiWindowFlags_NoMove = ImGuiWindowFlags_.ImGuiWindowFlags_NoMove;
alias ImGuiWindowFlags_NoScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_NoScrollbar;
alias ImGuiWindowFlags_NoScrollWithMouse = ImGuiWindowFlags_.ImGuiWindowFlags_NoScrollWithMouse;
alias ImGuiWindowFlags_NoCollapse = ImGuiWindowFlags_.ImGuiWindowFlags_NoCollapse;
alias ImGuiWindowFlags_AlwaysAutoResize = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysAutoResize;
alias ImGuiWindowFlags_NoBackground = ImGuiWindowFlags_.ImGuiWindowFlags_NoBackground;
alias ImGuiWindowFlags_NoSavedSettings = ImGuiWindowFlags_.ImGuiWindowFlags_NoSavedSettings;
alias ImGuiWindowFlags_NoMouseInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoMouseInputs;
alias ImGuiWindowFlags_MenuBar = ImGuiWindowFlags_.ImGuiWindowFlags_MenuBar;
alias ImGuiWindowFlags_HorizontalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_HorizontalScrollbar;
alias ImGuiWindowFlags_NoFocusOnAppearing = ImGuiWindowFlags_.ImGuiWindowFlags_NoFocusOnAppearing;
alias ImGuiWindowFlags_NoBringToFrontOnFocus = ImGuiWindowFlags_.ImGuiWindowFlags_NoBringToFrontOnFocus;
alias ImGuiWindowFlags_AlwaysVerticalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysVerticalScrollbar;
alias ImGuiWindowFlags_AlwaysHorizontalScrollbar = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysHorizontalScrollbar;
alias ImGuiWindowFlags_AlwaysUseWindowPadding = ImGuiWindowFlags_.ImGuiWindowFlags_AlwaysUseWindowPadding;
alias ImGuiWindowFlags_NoNavInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoNavInputs;
alias ImGuiWindowFlags_NoNavFocus = ImGuiWindowFlags_.ImGuiWindowFlags_NoNavFocus;
alias ImGuiWindowFlags_UnsavedDocument = ImGuiWindowFlags_.ImGuiWindowFlags_UnsavedDocument;
alias ImGuiWindowFlags_NoNav = ImGuiWindowFlags_.ImGuiWindowFlags_NoNav;
alias ImGuiWindowFlags_NoDecoration = ImGuiWindowFlags_.ImGuiWindowFlags_NoDecoration;
alias ImGuiWindowFlags_NoInputs = ImGuiWindowFlags_.ImGuiWindowFlags_NoInputs;
alias ImGuiWindowFlags_NavFlattened = ImGuiWindowFlags_.ImGuiWindowFlags_NavFlattened;
alias ImGuiWindowFlags_ChildWindow = ImGuiWindowFlags_.ImGuiWindowFlags_ChildWindow;
alias ImGuiWindowFlags_Tooltip = ImGuiWindowFlags_.ImGuiWindowFlags_Tooltip;
alias ImGuiWindowFlags_Popup = ImGuiWindowFlags_.ImGuiWindowFlags_Popup;
alias ImGuiWindowFlags_Modal = ImGuiWindowFlags_.ImGuiWindowFlags_Modal;
alias ImGuiWindowFlags_ChildMenu = ImGuiWindowFlags_.ImGuiWindowFlags_ChildMenu;

enum ImGuiInputTextFlags_
{
    ImGuiInputTextFlags_None = 0, 
    ImGuiInputTextFlags_CharsDecimal = 1, 
    ImGuiInputTextFlags_CharsHexadecimal = 2, 
    ImGuiInputTextFlags_CharsUppercase = 4, 
    ImGuiInputTextFlags_CharsNoBlank = 8, 
    ImGuiInputTextFlags_AutoSelectAll = 16, 
    ImGuiInputTextFlags_EnterReturnsTrue = 32, 
    ImGuiInputTextFlags_CallbackCompletion = 64, 
    ImGuiInputTextFlags_CallbackHistory = 128, 
    ImGuiInputTextFlags_CallbackAlways = 256, 
    ImGuiInputTextFlags_CallbackCharFilter = 512, 
    ImGuiInputTextFlags_AllowTabInput = 1024, 
    ImGuiInputTextFlags_CtrlEnterForNewLine = 2048, 
    ImGuiInputTextFlags_NoHorizontalScroll = 4096, 
    ImGuiInputTextFlags_AlwaysOverwrite = 8192, 
    ImGuiInputTextFlags_ReadOnly = 16384, 
    ImGuiInputTextFlags_Password = 32768, 
    ImGuiInputTextFlags_NoUndoRedo = 65536, 
    ImGuiInputTextFlags_CharsScientific = 131072, 
    ImGuiInputTextFlags_CallbackResize = 262144, 
    ImGuiInputTextFlags_CallbackEdit = 524288, 
    ImGuiInputTextFlags_AlwaysInsertMode = 8192, 
}

alias ImGuiInputTextFlags_None = ImGuiInputTextFlags_.ImGuiInputTextFlags_None;
alias ImGuiInputTextFlags_CharsDecimal = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsDecimal;
alias ImGuiInputTextFlags_CharsHexadecimal = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsHexadecimal;
alias ImGuiInputTextFlags_CharsUppercase = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsUppercase;
alias ImGuiInputTextFlags_CharsNoBlank = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsNoBlank;
alias ImGuiInputTextFlags_AutoSelectAll = ImGuiInputTextFlags_.ImGuiInputTextFlags_AutoSelectAll;
alias ImGuiInputTextFlags_EnterReturnsTrue = ImGuiInputTextFlags_.ImGuiInputTextFlags_EnterReturnsTrue;
alias ImGuiInputTextFlags_CallbackCompletion = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackCompletion;
alias ImGuiInputTextFlags_CallbackHistory = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackHistory;
alias ImGuiInputTextFlags_CallbackAlways = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackAlways;
alias ImGuiInputTextFlags_CallbackCharFilter = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackCharFilter;
alias ImGuiInputTextFlags_AllowTabInput = ImGuiInputTextFlags_.ImGuiInputTextFlags_AllowTabInput;
alias ImGuiInputTextFlags_CtrlEnterForNewLine = ImGuiInputTextFlags_.ImGuiInputTextFlags_CtrlEnterForNewLine;
alias ImGuiInputTextFlags_NoHorizontalScroll = ImGuiInputTextFlags_.ImGuiInputTextFlags_NoHorizontalScroll;
alias ImGuiInputTextFlags_AlwaysOverwrite = ImGuiInputTextFlags_.ImGuiInputTextFlags_AlwaysOverwrite;
alias ImGuiInputTextFlags_ReadOnly = ImGuiInputTextFlags_.ImGuiInputTextFlags_ReadOnly;
alias ImGuiInputTextFlags_Password = ImGuiInputTextFlags_.ImGuiInputTextFlags_Password;
alias ImGuiInputTextFlags_NoUndoRedo = ImGuiInputTextFlags_.ImGuiInputTextFlags_NoUndoRedo;
alias ImGuiInputTextFlags_CharsScientific = ImGuiInputTextFlags_.ImGuiInputTextFlags_CharsScientific;
alias ImGuiInputTextFlags_CallbackResize = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackResize;
alias ImGuiInputTextFlags_CallbackEdit = ImGuiInputTextFlags_.ImGuiInputTextFlags_CallbackEdit;
alias ImGuiInputTextFlags_AlwaysInsertMode = ImGuiInputTextFlags_.ImGuiInputTextFlags_AlwaysInsertMode;

enum ImGuiTreeNodeFlags_
{
    ImGuiTreeNodeFlags_None = 0, 
    ImGuiTreeNodeFlags_Selected = 1, 
    ImGuiTreeNodeFlags_Framed = 2, 
    ImGuiTreeNodeFlags_AllowItemOverlap = 4, 
    ImGuiTreeNodeFlags_NoTreePushOnOpen = 8, 
    ImGuiTreeNodeFlags_NoAutoOpenOnLog = 16, 
    ImGuiTreeNodeFlags_DefaultOpen = 32, 
    ImGuiTreeNodeFlags_OpenOnDoubleClick = 64, 
    ImGuiTreeNodeFlags_OpenOnArrow = 128, 
    ImGuiTreeNodeFlags_Leaf = 256, 
    ImGuiTreeNodeFlags_Bullet = 512, 
    ImGuiTreeNodeFlags_FramePadding = 1024, 
    ImGuiTreeNodeFlags_SpanAvailWidth = 2048, 
    ImGuiTreeNodeFlags_SpanFullWidth = 4096, 
    ImGuiTreeNodeFlags_NavLeftJumpsBackHere = 8192, 
    ImGuiTreeNodeFlags_CollapsingHeader = 26, 
}

alias ImGuiTreeNodeFlags_None = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_None;
alias ImGuiTreeNodeFlags_Selected = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Selected;
alias ImGuiTreeNodeFlags_Framed = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Framed;
alias ImGuiTreeNodeFlags_AllowItemOverlap = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_AllowItemOverlap;
alias ImGuiTreeNodeFlags_NoTreePushOnOpen = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NoTreePushOnOpen;
alias ImGuiTreeNodeFlags_NoAutoOpenOnLog = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NoAutoOpenOnLog;
alias ImGuiTreeNodeFlags_DefaultOpen = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_DefaultOpen;
alias ImGuiTreeNodeFlags_OpenOnDoubleClick = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_OpenOnDoubleClick;
alias ImGuiTreeNodeFlags_OpenOnArrow = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_OpenOnArrow;
alias ImGuiTreeNodeFlags_Leaf = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Leaf;
alias ImGuiTreeNodeFlags_Bullet = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_Bullet;
alias ImGuiTreeNodeFlags_FramePadding = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_FramePadding;
alias ImGuiTreeNodeFlags_SpanAvailWidth = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_SpanAvailWidth;
alias ImGuiTreeNodeFlags_SpanFullWidth = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_SpanFullWidth;
alias ImGuiTreeNodeFlags_NavLeftJumpsBackHere = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_NavLeftJumpsBackHere;
alias ImGuiTreeNodeFlags_CollapsingHeader = ImGuiTreeNodeFlags_.ImGuiTreeNodeFlags_CollapsingHeader;

enum ImGuiPopupFlags_
{
    ImGuiPopupFlags_None = 0, 
    ImGuiPopupFlags_MouseButtonLeft = 0, 
    ImGuiPopupFlags_MouseButtonRight = 1, 
    ImGuiPopupFlags_MouseButtonMiddle = 2, 
    ImGuiPopupFlags_MouseButtonMask_ = 31, 
    ImGuiPopupFlags_MouseButtonDefault_ = 1, 
    ImGuiPopupFlags_NoOpenOverExistingPopup = 32, 
    ImGuiPopupFlags_NoOpenOverItems = 64, 
    ImGuiPopupFlags_AnyPopupId = 128, 
    ImGuiPopupFlags_AnyPopupLevel = 256, 
    ImGuiPopupFlags_AnyPopup = 384, 
}

alias ImGuiPopupFlags_None = ImGuiPopupFlags_.ImGuiPopupFlags_None;
alias ImGuiPopupFlags_MouseButtonLeft = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonLeft;
alias ImGuiPopupFlags_MouseButtonRight = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonRight;
alias ImGuiPopupFlags_MouseButtonMiddle = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonMiddle;
alias ImGuiPopupFlags_MouseButtonMask_ = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonMask_;
alias ImGuiPopupFlags_MouseButtonDefault_ = ImGuiPopupFlags_.ImGuiPopupFlags_MouseButtonDefault_;
alias ImGuiPopupFlags_NoOpenOverExistingPopup = ImGuiPopupFlags_.ImGuiPopupFlags_NoOpenOverExistingPopup;
alias ImGuiPopupFlags_NoOpenOverItems = ImGuiPopupFlags_.ImGuiPopupFlags_NoOpenOverItems;
alias ImGuiPopupFlags_AnyPopupId = ImGuiPopupFlags_.ImGuiPopupFlags_AnyPopupId;
alias ImGuiPopupFlags_AnyPopupLevel = ImGuiPopupFlags_.ImGuiPopupFlags_AnyPopupLevel;
alias ImGuiPopupFlags_AnyPopup = ImGuiPopupFlags_.ImGuiPopupFlags_AnyPopup;

enum ImGuiSelectableFlags_
{
    ImGuiSelectableFlags_None = 0, 
    ImGuiSelectableFlags_DontClosePopups = 1, 
    ImGuiSelectableFlags_SpanAllColumns = 2, 
    ImGuiSelectableFlags_AllowDoubleClick = 4, 
    ImGuiSelectableFlags_Disabled = 8, 
    ImGuiSelectableFlags_AllowItemOverlap = 16, 
}

alias ImGuiSelectableFlags_None = ImGuiSelectableFlags_.ImGuiSelectableFlags_None;
alias ImGuiSelectableFlags_DontClosePopups = ImGuiSelectableFlags_.ImGuiSelectableFlags_DontClosePopups;
alias ImGuiSelectableFlags_SpanAllColumns = ImGuiSelectableFlags_.ImGuiSelectableFlags_SpanAllColumns;
alias ImGuiSelectableFlags_AllowDoubleClick = ImGuiSelectableFlags_.ImGuiSelectableFlags_AllowDoubleClick;
alias ImGuiSelectableFlags_Disabled = ImGuiSelectableFlags_.ImGuiSelectableFlags_Disabled;
alias ImGuiSelectableFlags_AllowItemOverlap = ImGuiSelectableFlags_.ImGuiSelectableFlags_AllowItemOverlap;

enum ImGuiComboFlags_
{
    ImGuiComboFlags_None = 0, 
    ImGuiComboFlags_PopupAlignLeft = 1, 
    ImGuiComboFlags_HeightSmall = 2, 
    ImGuiComboFlags_HeightRegular = 4, 
    ImGuiComboFlags_HeightLarge = 8, 
    ImGuiComboFlags_HeightLargest = 16, 
    ImGuiComboFlags_NoArrowButton = 32, 
    ImGuiComboFlags_NoPreview = 64, 
    ImGuiComboFlags_HeightMask_ = 30, 
}

alias ImGuiComboFlags_None = ImGuiComboFlags_.ImGuiComboFlags_None;
alias ImGuiComboFlags_PopupAlignLeft = ImGuiComboFlags_.ImGuiComboFlags_PopupAlignLeft;
alias ImGuiComboFlags_HeightSmall = ImGuiComboFlags_.ImGuiComboFlags_HeightSmall;
alias ImGuiComboFlags_HeightRegular = ImGuiComboFlags_.ImGuiComboFlags_HeightRegular;
alias ImGuiComboFlags_HeightLarge = ImGuiComboFlags_.ImGuiComboFlags_HeightLarge;
alias ImGuiComboFlags_HeightLargest = ImGuiComboFlags_.ImGuiComboFlags_HeightLargest;
alias ImGuiComboFlags_NoArrowButton = ImGuiComboFlags_.ImGuiComboFlags_NoArrowButton;
alias ImGuiComboFlags_NoPreview = ImGuiComboFlags_.ImGuiComboFlags_NoPreview;
alias ImGuiComboFlags_HeightMask_ = ImGuiComboFlags_.ImGuiComboFlags_HeightMask_;

enum ImGuiTabBarFlags_
{
    ImGuiTabBarFlags_None = 0, 
    ImGuiTabBarFlags_Reorderable = 1, 
    ImGuiTabBarFlags_AutoSelectNewTabs = 2, 
    ImGuiTabBarFlags_TabListPopupButton = 4, 
    ImGuiTabBarFlags_NoCloseWithMiddleMouseButton = 8, 
    ImGuiTabBarFlags_NoTabListScrollingButtons = 16, 
    ImGuiTabBarFlags_NoTooltip = 32, 
    ImGuiTabBarFlags_FittingPolicyResizeDown = 64, 
    ImGuiTabBarFlags_FittingPolicyScroll = 128, 
    ImGuiTabBarFlags_FittingPolicyMask_ = 192, 
    ImGuiTabBarFlags_FittingPolicyDefault_ = 64, 
}

alias ImGuiTabBarFlags_None = ImGuiTabBarFlags_.ImGuiTabBarFlags_None;
alias ImGuiTabBarFlags_Reorderable = ImGuiTabBarFlags_.ImGuiTabBarFlags_Reorderable;
alias ImGuiTabBarFlags_AutoSelectNewTabs = ImGuiTabBarFlags_.ImGuiTabBarFlags_AutoSelectNewTabs;
alias ImGuiTabBarFlags_TabListPopupButton = ImGuiTabBarFlags_.ImGuiTabBarFlags_TabListPopupButton;
alias ImGuiTabBarFlags_NoCloseWithMiddleMouseButton = ImGuiTabBarFlags_.ImGuiTabBarFlags_NoCloseWithMiddleMouseButton;
alias ImGuiTabBarFlags_NoTabListScrollingButtons = ImGuiTabBarFlags_.ImGuiTabBarFlags_NoTabListScrollingButtons;
alias ImGuiTabBarFlags_NoTooltip = ImGuiTabBarFlags_.ImGuiTabBarFlags_NoTooltip;
alias ImGuiTabBarFlags_FittingPolicyResizeDown = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyResizeDown;
alias ImGuiTabBarFlags_FittingPolicyScroll = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyScroll;
alias ImGuiTabBarFlags_FittingPolicyMask_ = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyMask_;
alias ImGuiTabBarFlags_FittingPolicyDefault_ = ImGuiTabBarFlags_.ImGuiTabBarFlags_FittingPolicyDefault_;

enum ImGuiTabItemFlags_
{
    ImGuiTabItemFlags_None = 0, 
    ImGuiTabItemFlags_UnsavedDocument = 1, 
    ImGuiTabItemFlags_SetSelected = 2, 
    ImGuiTabItemFlags_NoCloseWithMiddleMouseButton = 4, 
    ImGuiTabItemFlags_NoPushId = 8, 
    ImGuiTabItemFlags_NoTooltip = 16, 
    ImGuiTabItemFlags_NoReorder = 32, 
    ImGuiTabItemFlags_Leading = 64, 
    ImGuiTabItemFlags_Trailing = 128, 
}

alias ImGuiTabItemFlags_None = ImGuiTabItemFlags_.ImGuiTabItemFlags_None;
alias ImGuiTabItemFlags_UnsavedDocument = ImGuiTabItemFlags_.ImGuiTabItemFlags_UnsavedDocument;
alias ImGuiTabItemFlags_SetSelected = ImGuiTabItemFlags_.ImGuiTabItemFlags_SetSelected;
alias ImGuiTabItemFlags_NoCloseWithMiddleMouseButton = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoCloseWithMiddleMouseButton;
alias ImGuiTabItemFlags_NoPushId = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoPushId;
alias ImGuiTabItemFlags_NoTooltip = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoTooltip;
alias ImGuiTabItemFlags_NoReorder = ImGuiTabItemFlags_.ImGuiTabItemFlags_NoReorder;
alias ImGuiTabItemFlags_Leading = ImGuiTabItemFlags_.ImGuiTabItemFlags_Leading;
alias ImGuiTabItemFlags_Trailing = ImGuiTabItemFlags_.ImGuiTabItemFlags_Trailing;

enum ImGuiTableFlags_
{
    ImGuiTableFlags_None = 0, 
    ImGuiTableFlags_Resizable = 1, 
    ImGuiTableFlags_Reorderable = 2, 
    ImGuiTableFlags_Hideable = 4, 
    ImGuiTableFlags_Sortable = 8, 
    ImGuiTableFlags_NoSavedSettings = 16, 
    ImGuiTableFlags_ContextMenuInBody = 32, 
    ImGuiTableFlags_RowBg = 64, 
    ImGuiTableFlags_BordersInnerH = 128, 
    ImGuiTableFlags_BordersOuterH = 256, 
    ImGuiTableFlags_BordersInnerV = 512, 
    ImGuiTableFlags_BordersOuterV = 1024, 
    ImGuiTableFlags_BordersH = 384, 
    ImGuiTableFlags_BordersV = 1536, 
    ImGuiTableFlags_BordersInner = 640, 
    ImGuiTableFlags_BordersOuter = 1280, 
    ImGuiTableFlags_Borders = 1920, 
    ImGuiTableFlags_NoBordersInBody = 2048, 
    ImGuiTableFlags_NoBordersInBodyUntilResize = 4096, 
    ImGuiTableFlags_SizingFixedFit = 8192, 
    ImGuiTableFlags_SizingFixedSame = 16384, 
    ImGuiTableFlags_SizingStretchProp = 24576, 
    ImGuiTableFlags_SizingStretchSame = 32768, 
    ImGuiTableFlags_NoHostExtendX = 65536, 
    ImGuiTableFlags_NoHostExtendY = 131072, 
    ImGuiTableFlags_NoKeepColumnsVisible = 262144, 
    ImGuiTableFlags_PreciseWidths = 524288, 
    ImGuiTableFlags_NoClip = 1048576, 
    ImGuiTableFlags_PadOuterX = 2097152, 
    ImGuiTableFlags_NoPadOuterX = 4194304, 
    ImGuiTableFlags_NoPadInnerX = 8388608, 
    ImGuiTableFlags_ScrollX = 16777216, 
    ImGuiTableFlags_ScrollY = 33554432, 
    ImGuiTableFlags_SortMulti = 67108864, 
    ImGuiTableFlags_SortTristate = 134217728, 
    ImGuiTableFlags_SizingMask_ = 57344, 
}

alias ImGuiTableFlags_None = ImGuiTableFlags_.ImGuiTableFlags_None;
alias ImGuiTableFlags_Resizable = ImGuiTableFlags_.ImGuiTableFlags_Resizable;
alias ImGuiTableFlags_Reorderable = ImGuiTableFlags_.ImGuiTableFlags_Reorderable;
alias ImGuiTableFlags_Hideable = ImGuiTableFlags_.ImGuiTableFlags_Hideable;
alias ImGuiTableFlags_Sortable = ImGuiTableFlags_.ImGuiTableFlags_Sortable;
alias ImGuiTableFlags_NoSavedSettings = ImGuiTableFlags_.ImGuiTableFlags_NoSavedSettings;
alias ImGuiTableFlags_ContextMenuInBody = ImGuiTableFlags_.ImGuiTableFlags_ContextMenuInBody;
alias ImGuiTableFlags_RowBg = ImGuiTableFlags_.ImGuiTableFlags_RowBg;
alias ImGuiTableFlags_BordersInnerH = ImGuiTableFlags_.ImGuiTableFlags_BordersInnerH;
alias ImGuiTableFlags_BordersOuterH = ImGuiTableFlags_.ImGuiTableFlags_BordersOuterH;
alias ImGuiTableFlags_BordersInnerV = ImGuiTableFlags_.ImGuiTableFlags_BordersInnerV;
alias ImGuiTableFlags_BordersOuterV = ImGuiTableFlags_.ImGuiTableFlags_BordersOuterV;
alias ImGuiTableFlags_BordersH = ImGuiTableFlags_.ImGuiTableFlags_BordersH;
alias ImGuiTableFlags_BordersV = ImGuiTableFlags_.ImGuiTableFlags_BordersV;
alias ImGuiTableFlags_BordersInner = ImGuiTableFlags_.ImGuiTableFlags_BordersInner;
alias ImGuiTableFlags_BordersOuter = ImGuiTableFlags_.ImGuiTableFlags_BordersOuter;
alias ImGuiTableFlags_Borders = ImGuiTableFlags_.ImGuiTableFlags_Borders;
alias ImGuiTableFlags_NoBordersInBody = ImGuiTableFlags_.ImGuiTableFlags_NoBordersInBody;
alias ImGuiTableFlags_NoBordersInBodyUntilResize = ImGuiTableFlags_.ImGuiTableFlags_NoBordersInBodyUntilResize;
alias ImGuiTableFlags_SizingFixedFit = ImGuiTableFlags_.ImGuiTableFlags_SizingFixedFit;
alias ImGuiTableFlags_SizingFixedSame = ImGuiTableFlags_.ImGuiTableFlags_SizingFixedSame;
alias ImGuiTableFlags_SizingStretchProp = ImGuiTableFlags_.ImGuiTableFlags_SizingStretchProp;
alias ImGuiTableFlags_SizingStretchSame = ImGuiTableFlags_.ImGuiTableFlags_SizingStretchSame;
alias ImGuiTableFlags_NoHostExtendX = ImGuiTableFlags_.ImGuiTableFlags_NoHostExtendX;
alias ImGuiTableFlags_NoHostExtendY = ImGuiTableFlags_.ImGuiTableFlags_NoHostExtendY;
alias ImGuiTableFlags_NoKeepColumnsVisible = ImGuiTableFlags_.ImGuiTableFlags_NoKeepColumnsVisible;
alias ImGuiTableFlags_PreciseWidths = ImGuiTableFlags_.ImGuiTableFlags_PreciseWidths;
alias ImGuiTableFlags_NoClip = ImGuiTableFlags_.ImGuiTableFlags_NoClip;
alias ImGuiTableFlags_PadOuterX = ImGuiTableFlags_.ImGuiTableFlags_PadOuterX;
alias ImGuiTableFlags_NoPadOuterX = ImGuiTableFlags_.ImGuiTableFlags_NoPadOuterX;
alias ImGuiTableFlags_NoPadInnerX = ImGuiTableFlags_.ImGuiTableFlags_NoPadInnerX;
alias ImGuiTableFlags_ScrollX = ImGuiTableFlags_.ImGuiTableFlags_ScrollX;
alias ImGuiTableFlags_ScrollY = ImGuiTableFlags_.ImGuiTableFlags_ScrollY;
alias ImGuiTableFlags_SortMulti = ImGuiTableFlags_.ImGuiTableFlags_SortMulti;
alias ImGuiTableFlags_SortTristate = ImGuiTableFlags_.ImGuiTableFlags_SortTristate;
alias ImGuiTableFlags_SizingMask_ = ImGuiTableFlags_.ImGuiTableFlags_SizingMask_;

enum ImGuiTableColumnFlags_
{
    ImGuiTableColumnFlags_None = 0, 
    ImGuiTableColumnFlags_DefaultHide = 1, 
    ImGuiTableColumnFlags_DefaultSort = 2, 
    ImGuiTableColumnFlags_WidthStretch = 4, 
    ImGuiTableColumnFlags_WidthFixed = 8, 
    ImGuiTableColumnFlags_NoResize = 16, 
    ImGuiTableColumnFlags_NoReorder = 32, 
    ImGuiTableColumnFlags_NoHide = 64, 
    ImGuiTableColumnFlags_NoClip = 128, 
    ImGuiTableColumnFlags_NoSort = 256, 
    ImGuiTableColumnFlags_NoSortAscending = 512, 
    ImGuiTableColumnFlags_NoSortDescending = 1024, 
    ImGuiTableColumnFlags_NoHeaderWidth = 2048, 
    ImGuiTableColumnFlags_PreferSortAscending = 4096, 
    ImGuiTableColumnFlags_PreferSortDescending = 8192, 
    ImGuiTableColumnFlags_IndentEnable = 16384, 
    ImGuiTableColumnFlags_IndentDisable = 32768, 
    ImGuiTableColumnFlags_IsEnabled = 1048576, 
    ImGuiTableColumnFlags_IsVisible = 2097152, 
    ImGuiTableColumnFlags_IsSorted = 4194304, 
    ImGuiTableColumnFlags_IsHovered = 8388608, 
    ImGuiTableColumnFlags_WidthMask_ = 12, 
    ImGuiTableColumnFlags_IndentMask_ = 49152, 
    ImGuiTableColumnFlags_StatusMask_ = 15728640, 
    ImGuiTableColumnFlags_NoDirectResize_ = 1073741824, 
}

alias ImGuiTableColumnFlags_None = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_None;
alias ImGuiTableColumnFlags_DefaultHide = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_DefaultHide;
alias ImGuiTableColumnFlags_DefaultSort = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_DefaultSort;
alias ImGuiTableColumnFlags_WidthStretch = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_WidthStretch;
alias ImGuiTableColumnFlags_WidthFixed = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_WidthFixed;
alias ImGuiTableColumnFlags_NoResize = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoResize;
alias ImGuiTableColumnFlags_NoReorder = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoReorder;
alias ImGuiTableColumnFlags_NoHide = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoHide;
alias ImGuiTableColumnFlags_NoClip = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoClip;
alias ImGuiTableColumnFlags_NoSort = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoSort;
alias ImGuiTableColumnFlags_NoSortAscending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoSortAscending;
alias ImGuiTableColumnFlags_NoSortDescending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoSortDescending;
alias ImGuiTableColumnFlags_NoHeaderWidth = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoHeaderWidth;
alias ImGuiTableColumnFlags_PreferSortAscending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_PreferSortAscending;
alias ImGuiTableColumnFlags_PreferSortDescending = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_PreferSortDescending;
alias ImGuiTableColumnFlags_IndentEnable = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IndentEnable;
alias ImGuiTableColumnFlags_IndentDisable = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IndentDisable;
alias ImGuiTableColumnFlags_IsEnabled = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsEnabled;
alias ImGuiTableColumnFlags_IsVisible = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsVisible;
alias ImGuiTableColumnFlags_IsSorted = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsSorted;
alias ImGuiTableColumnFlags_IsHovered = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IsHovered;
alias ImGuiTableColumnFlags_WidthMask_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_WidthMask_;
alias ImGuiTableColumnFlags_IndentMask_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_IndentMask_;
alias ImGuiTableColumnFlags_StatusMask_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_StatusMask_;
alias ImGuiTableColumnFlags_NoDirectResize_ = ImGuiTableColumnFlags_.ImGuiTableColumnFlags_NoDirectResize_;

enum ImGuiTableRowFlags_
{
    ImGuiTableRowFlags_None = 0, 
    ImGuiTableRowFlags_Headers = 1, 
}

alias ImGuiTableRowFlags_None = ImGuiTableRowFlags_.ImGuiTableRowFlags_None;
alias ImGuiTableRowFlags_Headers = ImGuiTableRowFlags_.ImGuiTableRowFlags_Headers;

enum ImGuiTableBgTarget_
{
    ImGuiTableBgTarget_None = 0, 
    ImGuiTableBgTarget_RowBg0 = 1, 
    ImGuiTableBgTarget_RowBg1 = 2, 
    ImGuiTableBgTarget_CellBg = 3, 
}

alias ImGuiTableBgTarget_None = ImGuiTableBgTarget_.ImGuiTableBgTarget_None;
alias ImGuiTableBgTarget_RowBg0 = ImGuiTableBgTarget_.ImGuiTableBgTarget_RowBg0;
alias ImGuiTableBgTarget_RowBg1 = ImGuiTableBgTarget_.ImGuiTableBgTarget_RowBg1;
alias ImGuiTableBgTarget_CellBg = ImGuiTableBgTarget_.ImGuiTableBgTarget_CellBg;

enum ImGuiFocusedFlags_
{
    ImGuiFocusedFlags_None = 0, 
    ImGuiFocusedFlags_ChildWindows = 1, 
    ImGuiFocusedFlags_RootWindow = 2, 
    ImGuiFocusedFlags_AnyWindow = 4, 
    ImGuiFocusedFlags_RootAndChildWindows = 3, 
}

alias ImGuiFocusedFlags_None = ImGuiFocusedFlags_.ImGuiFocusedFlags_None;
alias ImGuiFocusedFlags_ChildWindows = ImGuiFocusedFlags_.ImGuiFocusedFlags_ChildWindows;
alias ImGuiFocusedFlags_RootWindow = ImGuiFocusedFlags_.ImGuiFocusedFlags_RootWindow;
alias ImGuiFocusedFlags_AnyWindow = ImGuiFocusedFlags_.ImGuiFocusedFlags_AnyWindow;
alias ImGuiFocusedFlags_RootAndChildWindows = ImGuiFocusedFlags_.ImGuiFocusedFlags_RootAndChildWindows;

enum ImGuiHoveredFlags_
{
    ImGuiHoveredFlags_None = 0, 
    ImGuiHoveredFlags_ChildWindows = 1, 
    ImGuiHoveredFlags_RootWindow = 2, 
    ImGuiHoveredFlags_AnyWindow = 4, 
    ImGuiHoveredFlags_AllowWhenBlockedByPopup = 8, 
    ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = 32, 
    ImGuiHoveredFlags_AllowWhenOverlapped = 64, 
    ImGuiHoveredFlags_AllowWhenDisabled = 128, 
    ImGuiHoveredFlags_RectOnly = 104, 
    ImGuiHoveredFlags_RootAndChildWindows = 3, 
}

alias ImGuiHoveredFlags_None = ImGuiHoveredFlags_.ImGuiHoveredFlags_None;
alias ImGuiHoveredFlags_ChildWindows = ImGuiHoveredFlags_.ImGuiHoveredFlags_ChildWindows;
alias ImGuiHoveredFlags_RootWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_RootWindow;
alias ImGuiHoveredFlags_AnyWindow = ImGuiHoveredFlags_.ImGuiHoveredFlags_AnyWindow;
alias ImGuiHoveredFlags_AllowWhenBlockedByPopup = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenBlockedByPopup;
alias ImGuiHoveredFlags_AllowWhenBlockedByActiveItem = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenBlockedByActiveItem;
alias ImGuiHoveredFlags_AllowWhenOverlapped = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenOverlapped;
alias ImGuiHoveredFlags_AllowWhenDisabled = ImGuiHoveredFlags_.ImGuiHoveredFlags_AllowWhenDisabled;
alias ImGuiHoveredFlags_RectOnly = ImGuiHoveredFlags_.ImGuiHoveredFlags_RectOnly;
alias ImGuiHoveredFlags_RootAndChildWindows = ImGuiHoveredFlags_.ImGuiHoveredFlags_RootAndChildWindows;

enum ImGuiDragDropFlags_
{
    ImGuiDragDropFlags_None = 0, 
    ImGuiDragDropFlags_SourceNoPreviewTooltip = 1, 
    ImGuiDragDropFlags_SourceNoDisableHover = 2, 
    ImGuiDragDropFlags_SourceNoHoldToOpenOthers = 4, 
    ImGuiDragDropFlags_SourceAllowNullID = 8, 
    ImGuiDragDropFlags_SourceExtern = 16, 
    ImGuiDragDropFlags_SourceAutoExpirePayload = 32, 
    ImGuiDragDropFlags_AcceptBeforeDelivery = 1024, 
    ImGuiDragDropFlags_AcceptNoDrawDefaultRect = 2048, 
    ImGuiDragDropFlags_AcceptNoPreviewTooltip = 4096, 
    ImGuiDragDropFlags_AcceptPeekOnly = 3072, 
}

alias ImGuiDragDropFlags_None = ImGuiDragDropFlags_.ImGuiDragDropFlags_None;
alias ImGuiDragDropFlags_SourceNoPreviewTooltip = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoPreviewTooltip;
alias ImGuiDragDropFlags_SourceNoDisableHover = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoDisableHover;
alias ImGuiDragDropFlags_SourceNoHoldToOpenOthers = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceNoHoldToOpenOthers;
alias ImGuiDragDropFlags_SourceAllowNullID = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceAllowNullID;
alias ImGuiDragDropFlags_SourceExtern = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceExtern;
alias ImGuiDragDropFlags_SourceAutoExpirePayload = ImGuiDragDropFlags_.ImGuiDragDropFlags_SourceAutoExpirePayload;
alias ImGuiDragDropFlags_AcceptBeforeDelivery = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptBeforeDelivery;
alias ImGuiDragDropFlags_AcceptNoDrawDefaultRect = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptNoDrawDefaultRect;
alias ImGuiDragDropFlags_AcceptNoPreviewTooltip = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptNoPreviewTooltip;
alias ImGuiDragDropFlags_AcceptPeekOnly = ImGuiDragDropFlags_.ImGuiDragDropFlags_AcceptPeekOnly;

enum ImGuiDataType_
{
    ImGuiDataType_S8 = 0, 
    ImGuiDataType_U8 = 1, 
    ImGuiDataType_S16 = 2, 
    ImGuiDataType_U16 = 3, 
    ImGuiDataType_S32 = 4, 
    ImGuiDataType_U32 = 5, 
    ImGuiDataType_S64 = 6, 
    ImGuiDataType_U64 = 7, 
    ImGuiDataType_Float = 8, 
    ImGuiDataType_Double = 9, 
    ImGuiDataType_COUNT = 10, 
}

alias ImGuiDataType_S8 = ImGuiDataType_.ImGuiDataType_S8;
alias ImGuiDataType_U8 = ImGuiDataType_.ImGuiDataType_U8;
alias ImGuiDataType_S16 = ImGuiDataType_.ImGuiDataType_S16;
alias ImGuiDataType_U16 = ImGuiDataType_.ImGuiDataType_U16;
alias ImGuiDataType_S32 = ImGuiDataType_.ImGuiDataType_S32;
alias ImGuiDataType_U32 = ImGuiDataType_.ImGuiDataType_U32;
alias ImGuiDataType_S64 = ImGuiDataType_.ImGuiDataType_S64;
alias ImGuiDataType_U64 = ImGuiDataType_.ImGuiDataType_U64;
alias ImGuiDataType_Float = ImGuiDataType_.ImGuiDataType_Float;
alias ImGuiDataType_Double = ImGuiDataType_.ImGuiDataType_Double;
alias ImGuiDataType_COUNT = ImGuiDataType_.ImGuiDataType_COUNT;

enum ImGuiDir_
{
    ImGuiDir_None = -1, 
    ImGuiDir_Left = 0, 
    ImGuiDir_Right = 1, 
    ImGuiDir_Up = 2, 
    ImGuiDir_Down = 3, 
    ImGuiDir_COUNT = 4, 
}

alias ImGuiDir_None = ImGuiDir_.ImGuiDir_None;
alias ImGuiDir_Left = ImGuiDir_.ImGuiDir_Left;
alias ImGuiDir_Right = ImGuiDir_.ImGuiDir_Right;
alias ImGuiDir_Up = ImGuiDir_.ImGuiDir_Up;
alias ImGuiDir_Down = ImGuiDir_.ImGuiDir_Down;
alias ImGuiDir_COUNT = ImGuiDir_.ImGuiDir_COUNT;

enum ImGuiSortDirection_
{
    ImGuiSortDirection_None = 0, 
    ImGuiSortDirection_Ascending = 1, 
    ImGuiSortDirection_Descending = 2, 
}

alias ImGuiSortDirection_None = ImGuiSortDirection_.ImGuiSortDirection_None;
alias ImGuiSortDirection_Ascending = ImGuiSortDirection_.ImGuiSortDirection_Ascending;
alias ImGuiSortDirection_Descending = ImGuiSortDirection_.ImGuiSortDirection_Descending;

enum ImGuiKey_
{
    ImGuiKey_Tab = 0, 
    ImGuiKey_LeftArrow = 1, 
    ImGuiKey_RightArrow = 2, 
    ImGuiKey_UpArrow = 3, 
    ImGuiKey_DownArrow = 4, 
    ImGuiKey_PageUp = 5, 
    ImGuiKey_PageDown = 6, 
    ImGuiKey_Home = 7, 
    ImGuiKey_End = 8, 
    ImGuiKey_Insert = 9, 
    ImGuiKey_Delete = 10, 
    ImGuiKey_Backspace = 11, 
    ImGuiKey_Space = 12, 
    ImGuiKey_Enter = 13, 
    ImGuiKey_Escape = 14, 
    ImGuiKey_KeyPadEnter = 15, 
    ImGuiKey_A = 16, 
    ImGuiKey_C = 17, 
    ImGuiKey_V = 18, 
    ImGuiKey_X = 19, 
    ImGuiKey_Y = 20, 
    ImGuiKey_Z = 21, 
    ImGuiKey_COUNT = 22, 
}

alias ImGuiKey_Tab = ImGuiKey_.ImGuiKey_Tab;
alias ImGuiKey_LeftArrow = ImGuiKey_.ImGuiKey_LeftArrow;
alias ImGuiKey_RightArrow = ImGuiKey_.ImGuiKey_RightArrow;
alias ImGuiKey_UpArrow = ImGuiKey_.ImGuiKey_UpArrow;
alias ImGuiKey_DownArrow = ImGuiKey_.ImGuiKey_DownArrow;
alias ImGuiKey_PageUp = ImGuiKey_.ImGuiKey_PageUp;
alias ImGuiKey_PageDown = ImGuiKey_.ImGuiKey_PageDown;
alias ImGuiKey_Home = ImGuiKey_.ImGuiKey_Home;
alias ImGuiKey_End = ImGuiKey_.ImGuiKey_End;
alias ImGuiKey_Insert = ImGuiKey_.ImGuiKey_Insert;
alias ImGuiKey_Delete = ImGuiKey_.ImGuiKey_Delete;
alias ImGuiKey_Backspace = ImGuiKey_.ImGuiKey_Backspace;
alias ImGuiKey_Space = ImGuiKey_.ImGuiKey_Space;
alias ImGuiKey_Enter = ImGuiKey_.ImGuiKey_Enter;
alias ImGuiKey_Escape = ImGuiKey_.ImGuiKey_Escape;
alias ImGuiKey_KeyPadEnter = ImGuiKey_.ImGuiKey_KeyPadEnter;
alias ImGuiKey_A = ImGuiKey_.ImGuiKey_A;
alias ImGuiKey_C = ImGuiKey_.ImGuiKey_C;
alias ImGuiKey_V = ImGuiKey_.ImGuiKey_V;
alias ImGuiKey_X = ImGuiKey_.ImGuiKey_X;
alias ImGuiKey_Y = ImGuiKey_.ImGuiKey_Y;
alias ImGuiKey_Z = ImGuiKey_.ImGuiKey_Z;
alias ImGuiKey_COUNT = ImGuiKey_.ImGuiKey_COUNT;

enum ImGuiKeyModFlags_
{
    ImGuiKeyModFlags_None = 0, 
    ImGuiKeyModFlags_Ctrl = 1, 
    ImGuiKeyModFlags_Shift = 2, 
    ImGuiKeyModFlags_Alt = 4, 
    ImGuiKeyModFlags_Super = 8, 
}

alias ImGuiKeyModFlags_None = ImGuiKeyModFlags_.ImGuiKeyModFlags_None;
alias ImGuiKeyModFlags_Ctrl = ImGuiKeyModFlags_.ImGuiKeyModFlags_Ctrl;
alias ImGuiKeyModFlags_Shift = ImGuiKeyModFlags_.ImGuiKeyModFlags_Shift;
alias ImGuiKeyModFlags_Alt = ImGuiKeyModFlags_.ImGuiKeyModFlags_Alt;
alias ImGuiKeyModFlags_Super = ImGuiKeyModFlags_.ImGuiKeyModFlags_Super;

enum ImGuiNavInput_
{
    ImGuiNavInput_Activate = 0, 
    ImGuiNavInput_Cancel = 1, 
    ImGuiNavInput_Input = 2, 
    ImGuiNavInput_Menu = 3, 
    ImGuiNavInput_DpadLeft = 4, 
    ImGuiNavInput_DpadRight = 5, 
    ImGuiNavInput_DpadUp = 6, 
    ImGuiNavInput_DpadDown = 7, 
    ImGuiNavInput_LStickLeft = 8, 
    ImGuiNavInput_LStickRight = 9, 
    ImGuiNavInput_LStickUp = 10, 
    ImGuiNavInput_LStickDown = 11, 
    ImGuiNavInput_FocusPrev = 12, 
    ImGuiNavInput_FocusNext = 13, 
    ImGuiNavInput_TweakSlow = 14, 
    ImGuiNavInput_TweakFast = 15, 
    ImGuiNavInput_KeyMenu_ = 16, 
    ImGuiNavInput_KeyLeft_ = 17, 
    ImGuiNavInput_KeyRight_ = 18, 
    ImGuiNavInput_KeyUp_ = 19, 
    ImGuiNavInput_KeyDown_ = 20, 
    ImGuiNavInput_COUNT = 21, 
    ImGuiNavInput_InternalStart_ = 16, 
}

alias ImGuiNavInput_Activate = ImGuiNavInput_.ImGuiNavInput_Activate;
alias ImGuiNavInput_Cancel = ImGuiNavInput_.ImGuiNavInput_Cancel;
alias ImGuiNavInput_Input = ImGuiNavInput_.ImGuiNavInput_Input;
alias ImGuiNavInput_Menu = ImGuiNavInput_.ImGuiNavInput_Menu;
alias ImGuiNavInput_DpadLeft = ImGuiNavInput_.ImGuiNavInput_DpadLeft;
alias ImGuiNavInput_DpadRight = ImGuiNavInput_.ImGuiNavInput_DpadRight;
alias ImGuiNavInput_DpadUp = ImGuiNavInput_.ImGuiNavInput_DpadUp;
alias ImGuiNavInput_DpadDown = ImGuiNavInput_.ImGuiNavInput_DpadDown;
alias ImGuiNavInput_LStickLeft = ImGuiNavInput_.ImGuiNavInput_LStickLeft;
alias ImGuiNavInput_LStickRight = ImGuiNavInput_.ImGuiNavInput_LStickRight;
alias ImGuiNavInput_LStickUp = ImGuiNavInput_.ImGuiNavInput_LStickUp;
alias ImGuiNavInput_LStickDown = ImGuiNavInput_.ImGuiNavInput_LStickDown;
alias ImGuiNavInput_FocusPrev = ImGuiNavInput_.ImGuiNavInput_FocusPrev;
alias ImGuiNavInput_FocusNext = ImGuiNavInput_.ImGuiNavInput_FocusNext;
alias ImGuiNavInput_TweakSlow = ImGuiNavInput_.ImGuiNavInput_TweakSlow;
alias ImGuiNavInput_TweakFast = ImGuiNavInput_.ImGuiNavInput_TweakFast;
alias ImGuiNavInput_KeyMenu_ = ImGuiNavInput_.ImGuiNavInput_KeyMenu_;
alias ImGuiNavInput_KeyLeft_ = ImGuiNavInput_.ImGuiNavInput_KeyLeft_;
alias ImGuiNavInput_KeyRight_ = ImGuiNavInput_.ImGuiNavInput_KeyRight_;
alias ImGuiNavInput_KeyUp_ = ImGuiNavInput_.ImGuiNavInput_KeyUp_;
alias ImGuiNavInput_KeyDown_ = ImGuiNavInput_.ImGuiNavInput_KeyDown_;
alias ImGuiNavInput_COUNT = ImGuiNavInput_.ImGuiNavInput_COUNT;
alias ImGuiNavInput_InternalStart_ = ImGuiNavInput_.ImGuiNavInput_InternalStart_;

enum ImGuiConfigFlags_
{
    ImGuiConfigFlags_None = 0, 
    ImGuiConfigFlags_NavEnableKeyboard = 1, 
    ImGuiConfigFlags_NavEnableGamepad = 2, 
    ImGuiConfigFlags_NavEnableSetMousePos = 4, 
    ImGuiConfigFlags_NavNoCaptureKeyboard = 8, 
    ImGuiConfigFlags_NoMouse = 16, 
    ImGuiConfigFlags_NoMouseCursorChange = 32, 
    ImGuiConfigFlags_IsSRGB = 1048576, 
    ImGuiConfigFlags_IsTouchScreen = 2097152, 
}

alias ImGuiConfigFlags_None = ImGuiConfigFlags_.ImGuiConfigFlags_None;
alias ImGuiConfigFlags_NavEnableKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableKeyboard;
alias ImGuiConfigFlags_NavEnableGamepad = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableGamepad;
alias ImGuiConfigFlags_NavEnableSetMousePos = ImGuiConfigFlags_.ImGuiConfigFlags_NavEnableSetMousePos;
alias ImGuiConfigFlags_NavNoCaptureKeyboard = ImGuiConfigFlags_.ImGuiConfigFlags_NavNoCaptureKeyboard;
alias ImGuiConfigFlags_NoMouse = ImGuiConfigFlags_.ImGuiConfigFlags_NoMouse;
alias ImGuiConfigFlags_NoMouseCursorChange = ImGuiConfigFlags_.ImGuiConfigFlags_NoMouseCursorChange;
alias ImGuiConfigFlags_IsSRGB = ImGuiConfigFlags_.ImGuiConfigFlags_IsSRGB;
alias ImGuiConfigFlags_IsTouchScreen = ImGuiConfigFlags_.ImGuiConfigFlags_IsTouchScreen;

enum ImGuiBackendFlags_
{
    ImGuiBackendFlags_None = 0, 
    ImGuiBackendFlags_HasGamepad = 1, 
    ImGuiBackendFlags_HasMouseCursors = 2, 
    ImGuiBackendFlags_HasSetMousePos = 4, 
    ImGuiBackendFlags_RendererHasVtxOffset = 8, 
}

alias ImGuiBackendFlags_None = ImGuiBackendFlags_.ImGuiBackendFlags_None;
alias ImGuiBackendFlags_HasGamepad = ImGuiBackendFlags_.ImGuiBackendFlags_HasGamepad;
alias ImGuiBackendFlags_HasMouseCursors = ImGuiBackendFlags_.ImGuiBackendFlags_HasMouseCursors;
alias ImGuiBackendFlags_HasSetMousePos = ImGuiBackendFlags_.ImGuiBackendFlags_HasSetMousePos;
alias ImGuiBackendFlags_RendererHasVtxOffset = ImGuiBackendFlags_.ImGuiBackendFlags_RendererHasVtxOffset;

enum ImGuiCol_
{
    ImGuiCol_Text = 0, 
    ImGuiCol_TextDisabled = 1, 
    ImGuiCol_WindowBg = 2, 
    ImGuiCol_ChildBg = 3, 
    ImGuiCol_PopupBg = 4, 
    ImGuiCol_Border = 5, 
    ImGuiCol_BorderShadow = 6, 
    ImGuiCol_FrameBg = 7, 
    ImGuiCol_FrameBgHovered = 8, 
    ImGuiCol_FrameBgActive = 9, 
    ImGuiCol_TitleBg = 10, 
    ImGuiCol_TitleBgActive = 11, 
    ImGuiCol_TitleBgCollapsed = 12, 
    ImGuiCol_MenuBarBg = 13, 
    ImGuiCol_ScrollbarBg = 14, 
    ImGuiCol_ScrollbarGrab = 15, 
    ImGuiCol_ScrollbarGrabHovered = 16, 
    ImGuiCol_ScrollbarGrabActive = 17, 
    ImGuiCol_CheckMark = 18, 
    ImGuiCol_SliderGrab = 19, 
    ImGuiCol_SliderGrabActive = 20, 
    ImGuiCol_Button = 21, 
    ImGuiCol_ButtonHovered = 22, 
    ImGuiCol_ButtonActive = 23, 
    ImGuiCol_Header = 24, 
    ImGuiCol_HeaderHovered = 25, 
    ImGuiCol_HeaderActive = 26, 
    ImGuiCol_Separator = 27, 
    ImGuiCol_SeparatorHovered = 28, 
    ImGuiCol_SeparatorActive = 29, 
    ImGuiCol_ResizeGrip = 30, 
    ImGuiCol_ResizeGripHovered = 31, 
    ImGuiCol_ResizeGripActive = 32, 
    ImGuiCol_Tab = 33, 
    ImGuiCol_TabHovered = 34, 
    ImGuiCol_TabActive = 35, 
    ImGuiCol_TabUnfocused = 36, 
    ImGuiCol_TabUnfocusedActive = 37, 
    ImGuiCol_PlotLines = 38, 
    ImGuiCol_PlotLinesHovered = 39, 
    ImGuiCol_PlotHistogram = 40, 
    ImGuiCol_PlotHistogramHovered = 41, 
    ImGuiCol_TableHeaderBg = 42, 
    ImGuiCol_TableBorderStrong = 43, 
    ImGuiCol_TableBorderLight = 44, 
    ImGuiCol_TableRowBg = 45, 
    ImGuiCol_TableRowBgAlt = 46, 
    ImGuiCol_TextSelectedBg = 47, 
    ImGuiCol_DragDropTarget = 48, 
    ImGuiCol_NavHighlight = 49, 
    ImGuiCol_NavWindowingHighlight = 50, 
    ImGuiCol_NavWindowingDimBg = 51, 
    ImGuiCol_ModalWindowDimBg = 52, 
    ImGuiCol_COUNT = 53, 
}

alias ImGuiCol_Text = ImGuiCol_.ImGuiCol_Text;
alias ImGuiCol_TextDisabled = ImGuiCol_.ImGuiCol_TextDisabled;
alias ImGuiCol_WindowBg = ImGuiCol_.ImGuiCol_WindowBg;
alias ImGuiCol_ChildBg = ImGuiCol_.ImGuiCol_ChildBg;
alias ImGuiCol_PopupBg = ImGuiCol_.ImGuiCol_PopupBg;
alias ImGuiCol_Border = ImGuiCol_.ImGuiCol_Border;
alias ImGuiCol_BorderShadow = ImGuiCol_.ImGuiCol_BorderShadow;
alias ImGuiCol_FrameBg = ImGuiCol_.ImGuiCol_FrameBg;
alias ImGuiCol_FrameBgHovered = ImGuiCol_.ImGuiCol_FrameBgHovered;
alias ImGuiCol_FrameBgActive = ImGuiCol_.ImGuiCol_FrameBgActive;
alias ImGuiCol_TitleBg = ImGuiCol_.ImGuiCol_TitleBg;
alias ImGuiCol_TitleBgActive = ImGuiCol_.ImGuiCol_TitleBgActive;
alias ImGuiCol_TitleBgCollapsed = ImGuiCol_.ImGuiCol_TitleBgCollapsed;
alias ImGuiCol_MenuBarBg = ImGuiCol_.ImGuiCol_MenuBarBg;
alias ImGuiCol_ScrollbarBg = ImGuiCol_.ImGuiCol_ScrollbarBg;
alias ImGuiCol_ScrollbarGrab = ImGuiCol_.ImGuiCol_ScrollbarGrab;
alias ImGuiCol_ScrollbarGrabHovered = ImGuiCol_.ImGuiCol_ScrollbarGrabHovered;
alias ImGuiCol_ScrollbarGrabActive = ImGuiCol_.ImGuiCol_ScrollbarGrabActive;
alias ImGuiCol_CheckMark = ImGuiCol_.ImGuiCol_CheckMark;
alias ImGuiCol_SliderGrab = ImGuiCol_.ImGuiCol_SliderGrab;
alias ImGuiCol_SliderGrabActive = ImGuiCol_.ImGuiCol_SliderGrabActive;
alias ImGuiCol_Button = ImGuiCol_.ImGuiCol_Button;
alias ImGuiCol_ButtonHovered = ImGuiCol_.ImGuiCol_ButtonHovered;
alias ImGuiCol_ButtonActive = ImGuiCol_.ImGuiCol_ButtonActive;
alias ImGuiCol_Header = ImGuiCol_.ImGuiCol_Header;
alias ImGuiCol_HeaderHovered = ImGuiCol_.ImGuiCol_HeaderHovered;
alias ImGuiCol_HeaderActive = ImGuiCol_.ImGuiCol_HeaderActive;
alias ImGuiCol_Separator = ImGuiCol_.ImGuiCol_Separator;
alias ImGuiCol_SeparatorHovered = ImGuiCol_.ImGuiCol_SeparatorHovered;
alias ImGuiCol_SeparatorActive = ImGuiCol_.ImGuiCol_SeparatorActive;
alias ImGuiCol_ResizeGrip = ImGuiCol_.ImGuiCol_ResizeGrip;
alias ImGuiCol_ResizeGripHovered = ImGuiCol_.ImGuiCol_ResizeGripHovered;
alias ImGuiCol_ResizeGripActive = ImGuiCol_.ImGuiCol_ResizeGripActive;
alias ImGuiCol_Tab = ImGuiCol_.ImGuiCol_Tab;
alias ImGuiCol_TabHovered = ImGuiCol_.ImGuiCol_TabHovered;
alias ImGuiCol_TabActive = ImGuiCol_.ImGuiCol_TabActive;
alias ImGuiCol_TabUnfocused = ImGuiCol_.ImGuiCol_TabUnfocused;
alias ImGuiCol_TabUnfocusedActive = ImGuiCol_.ImGuiCol_TabUnfocusedActive;
alias ImGuiCol_PlotLines = ImGuiCol_.ImGuiCol_PlotLines;
alias ImGuiCol_PlotLinesHovered = ImGuiCol_.ImGuiCol_PlotLinesHovered;
alias ImGuiCol_PlotHistogram = ImGuiCol_.ImGuiCol_PlotHistogram;
alias ImGuiCol_PlotHistogramHovered = ImGuiCol_.ImGuiCol_PlotHistogramHovered;
alias ImGuiCol_TableHeaderBg = ImGuiCol_.ImGuiCol_TableHeaderBg;
alias ImGuiCol_TableBorderStrong = ImGuiCol_.ImGuiCol_TableBorderStrong;
alias ImGuiCol_TableBorderLight = ImGuiCol_.ImGuiCol_TableBorderLight;
alias ImGuiCol_TableRowBg = ImGuiCol_.ImGuiCol_TableRowBg;
alias ImGuiCol_TableRowBgAlt = ImGuiCol_.ImGuiCol_TableRowBgAlt;
alias ImGuiCol_TextSelectedBg = ImGuiCol_.ImGuiCol_TextSelectedBg;
alias ImGuiCol_DragDropTarget = ImGuiCol_.ImGuiCol_DragDropTarget;
alias ImGuiCol_NavHighlight = ImGuiCol_.ImGuiCol_NavHighlight;
alias ImGuiCol_NavWindowingHighlight = ImGuiCol_.ImGuiCol_NavWindowingHighlight;
alias ImGuiCol_NavWindowingDimBg = ImGuiCol_.ImGuiCol_NavWindowingDimBg;
alias ImGuiCol_ModalWindowDimBg = ImGuiCol_.ImGuiCol_ModalWindowDimBg;
alias ImGuiCol_COUNT = ImGuiCol_.ImGuiCol_COUNT;

enum ImGuiStyleVar_
{
    ImGuiStyleVar_Alpha = 0, 
    ImGuiStyleVar_WindowPadding = 1, 
    ImGuiStyleVar_WindowRounding = 2, 
    ImGuiStyleVar_WindowBorderSize = 3, 
    ImGuiStyleVar_WindowMinSize = 4, 
    ImGuiStyleVar_WindowTitleAlign = 5, 
    ImGuiStyleVar_ChildRounding = 6, 
    ImGuiStyleVar_ChildBorderSize = 7, 
    ImGuiStyleVar_PopupRounding = 8, 
    ImGuiStyleVar_PopupBorderSize = 9, 
    ImGuiStyleVar_FramePadding = 10, 
    ImGuiStyleVar_FrameRounding = 11, 
    ImGuiStyleVar_FrameBorderSize = 12, 
    ImGuiStyleVar_ItemSpacing = 13, 
    ImGuiStyleVar_ItemInnerSpacing = 14, 
    ImGuiStyleVar_IndentSpacing = 15, 
    ImGuiStyleVar_CellPadding = 16, 
    ImGuiStyleVar_ScrollbarSize = 17, 
    ImGuiStyleVar_ScrollbarRounding = 18, 
    ImGuiStyleVar_GrabMinSize = 19, 
    ImGuiStyleVar_GrabRounding = 20, 
    ImGuiStyleVar_TabRounding = 21, 
    ImGuiStyleVar_ButtonTextAlign = 22, 
    ImGuiStyleVar_SelectableTextAlign = 23, 
    ImGuiStyleVar_COUNT = 24, 
}

alias ImGuiStyleVar_Alpha = ImGuiStyleVar_.ImGuiStyleVar_Alpha;
alias ImGuiStyleVar_WindowPadding = ImGuiStyleVar_.ImGuiStyleVar_WindowPadding;
alias ImGuiStyleVar_WindowRounding = ImGuiStyleVar_.ImGuiStyleVar_WindowRounding;
alias ImGuiStyleVar_WindowBorderSize = ImGuiStyleVar_.ImGuiStyleVar_WindowBorderSize;
alias ImGuiStyleVar_WindowMinSize = ImGuiStyleVar_.ImGuiStyleVar_WindowMinSize;
alias ImGuiStyleVar_WindowTitleAlign = ImGuiStyleVar_.ImGuiStyleVar_WindowTitleAlign;
alias ImGuiStyleVar_ChildRounding = ImGuiStyleVar_.ImGuiStyleVar_ChildRounding;
alias ImGuiStyleVar_ChildBorderSize = ImGuiStyleVar_.ImGuiStyleVar_ChildBorderSize;
alias ImGuiStyleVar_PopupRounding = ImGuiStyleVar_.ImGuiStyleVar_PopupRounding;
alias ImGuiStyleVar_PopupBorderSize = ImGuiStyleVar_.ImGuiStyleVar_PopupBorderSize;
alias ImGuiStyleVar_FramePadding = ImGuiStyleVar_.ImGuiStyleVar_FramePadding;
alias ImGuiStyleVar_FrameRounding = ImGuiStyleVar_.ImGuiStyleVar_FrameRounding;
alias ImGuiStyleVar_FrameBorderSize = ImGuiStyleVar_.ImGuiStyleVar_FrameBorderSize;
alias ImGuiStyleVar_ItemSpacing = ImGuiStyleVar_.ImGuiStyleVar_ItemSpacing;
alias ImGuiStyleVar_ItemInnerSpacing = ImGuiStyleVar_.ImGuiStyleVar_ItemInnerSpacing;
alias ImGuiStyleVar_IndentSpacing = ImGuiStyleVar_.ImGuiStyleVar_IndentSpacing;
alias ImGuiStyleVar_CellPadding = ImGuiStyleVar_.ImGuiStyleVar_CellPadding;
alias ImGuiStyleVar_ScrollbarSize = ImGuiStyleVar_.ImGuiStyleVar_ScrollbarSize;
alias ImGuiStyleVar_ScrollbarRounding = ImGuiStyleVar_.ImGuiStyleVar_ScrollbarRounding;
alias ImGuiStyleVar_GrabMinSize = ImGuiStyleVar_.ImGuiStyleVar_GrabMinSize;
alias ImGuiStyleVar_GrabRounding = ImGuiStyleVar_.ImGuiStyleVar_GrabRounding;
alias ImGuiStyleVar_TabRounding = ImGuiStyleVar_.ImGuiStyleVar_TabRounding;
alias ImGuiStyleVar_ButtonTextAlign = ImGuiStyleVar_.ImGuiStyleVar_ButtonTextAlign;
alias ImGuiStyleVar_SelectableTextAlign = ImGuiStyleVar_.ImGuiStyleVar_SelectableTextAlign;
alias ImGuiStyleVar_COUNT = ImGuiStyleVar_.ImGuiStyleVar_COUNT;

enum ImGuiButtonFlags_
{
    ImGuiButtonFlags_None = 0, 
    ImGuiButtonFlags_MouseButtonLeft = 1, 
    ImGuiButtonFlags_MouseButtonRight = 2, 
    ImGuiButtonFlags_MouseButtonMiddle = 4, 
    ImGuiButtonFlags_MouseButtonMask_ = 7, 
    ImGuiButtonFlags_MouseButtonDefault_ = 1, 
}

alias ImGuiButtonFlags_None = ImGuiButtonFlags_.ImGuiButtonFlags_None;
alias ImGuiButtonFlags_MouseButtonLeft = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonLeft;
alias ImGuiButtonFlags_MouseButtonRight = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonRight;
alias ImGuiButtonFlags_MouseButtonMiddle = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonMiddle;
alias ImGuiButtonFlags_MouseButtonMask_ = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonMask_;
alias ImGuiButtonFlags_MouseButtonDefault_ = ImGuiButtonFlags_.ImGuiButtonFlags_MouseButtonDefault_;

enum ImGuiColorEditFlags_
{
    ImGuiColorEditFlags_None = 0, 
    ImGuiColorEditFlags_NoAlpha = 2, 
    ImGuiColorEditFlags_NoPicker = 4, 
    ImGuiColorEditFlags_NoOptions = 8, 
    ImGuiColorEditFlags_NoSmallPreview = 16, 
    ImGuiColorEditFlags_NoInputs = 32, 
    ImGuiColorEditFlags_NoTooltip = 64, 
    ImGuiColorEditFlags_NoLabel = 128, 
    ImGuiColorEditFlags_NoSidePreview = 256, 
    ImGuiColorEditFlags_NoDragDrop = 512, 
    ImGuiColorEditFlags_NoBorder = 1024, 
    ImGuiColorEditFlags_AlphaBar = 65536, 
    ImGuiColorEditFlags_AlphaPreview = 131072, 
    ImGuiColorEditFlags_AlphaPreviewHalf = 262144, 
    ImGuiColorEditFlags_HDR = 524288, 
    ImGuiColorEditFlags_DisplayRGB = 1048576, 
    ImGuiColorEditFlags_DisplayHSV = 2097152, 
    ImGuiColorEditFlags_DisplayHex = 4194304, 
    ImGuiColorEditFlags_Uint8 = 8388608, 
    ImGuiColorEditFlags_Float = 16777216, 
    ImGuiColorEditFlags_PickerHueBar = 33554432, 
    ImGuiColorEditFlags_PickerHueWheel = 67108864, 
    ImGuiColorEditFlags_InputRGB = 134217728, 
    ImGuiColorEditFlags_InputHSV = 268435456, 
    ImGuiColorEditFlags__OptionsDefault = 177209344, 
    ImGuiColorEditFlags__DisplayMask = 7340032, 
    ImGuiColorEditFlags__DataTypeMask = 25165824, 
    ImGuiColorEditFlags__PickerMask = 100663296, 
    ImGuiColorEditFlags__InputMask = 402653184, 
    ImGuiColorEditFlags_RGB = 1048576, 
    ImGuiColorEditFlags_HSV = 2097152, 
    ImGuiColorEditFlags_HEX = 4194304, 
}

alias ImGuiColorEditFlags_None = ImGuiColorEditFlags_.ImGuiColorEditFlags_None;
alias ImGuiColorEditFlags_NoAlpha = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoAlpha;
alias ImGuiColorEditFlags_NoPicker = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoPicker;
alias ImGuiColorEditFlags_NoOptions = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoOptions;
alias ImGuiColorEditFlags_NoSmallPreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoSmallPreview;
alias ImGuiColorEditFlags_NoInputs = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoInputs;
alias ImGuiColorEditFlags_NoTooltip = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoTooltip;
alias ImGuiColorEditFlags_NoLabel = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoLabel;
alias ImGuiColorEditFlags_NoSidePreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoSidePreview;
alias ImGuiColorEditFlags_NoDragDrop = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoDragDrop;
alias ImGuiColorEditFlags_NoBorder = ImGuiColorEditFlags_.ImGuiColorEditFlags_NoBorder;
alias ImGuiColorEditFlags_AlphaBar = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaBar;
alias ImGuiColorEditFlags_AlphaPreview = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaPreview;
alias ImGuiColorEditFlags_AlphaPreviewHalf = ImGuiColorEditFlags_.ImGuiColorEditFlags_AlphaPreviewHalf;
alias ImGuiColorEditFlags_HDR = ImGuiColorEditFlags_.ImGuiColorEditFlags_HDR;
alias ImGuiColorEditFlags_DisplayRGB = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayRGB;
alias ImGuiColorEditFlags_DisplayHSV = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayHSV;
alias ImGuiColorEditFlags_DisplayHex = ImGuiColorEditFlags_.ImGuiColorEditFlags_DisplayHex;
alias ImGuiColorEditFlags_Uint8 = ImGuiColorEditFlags_.ImGuiColorEditFlags_Uint8;
alias ImGuiColorEditFlags_Float = ImGuiColorEditFlags_.ImGuiColorEditFlags_Float;
alias ImGuiColorEditFlags_PickerHueBar = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerHueBar;
alias ImGuiColorEditFlags_PickerHueWheel = ImGuiColorEditFlags_.ImGuiColorEditFlags_PickerHueWheel;
alias ImGuiColorEditFlags_InputRGB = ImGuiColorEditFlags_.ImGuiColorEditFlags_InputRGB;
alias ImGuiColorEditFlags_InputHSV = ImGuiColorEditFlags_.ImGuiColorEditFlags_InputHSV;
alias ImGuiColorEditFlags__OptionsDefault = ImGuiColorEditFlags_.ImGuiColorEditFlags__OptionsDefault;
alias ImGuiColorEditFlags__DisplayMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__DisplayMask;
alias ImGuiColorEditFlags__DataTypeMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__DataTypeMask;
alias ImGuiColorEditFlags__PickerMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__PickerMask;
alias ImGuiColorEditFlags__InputMask = ImGuiColorEditFlags_.ImGuiColorEditFlags__InputMask;
alias ImGuiColorEditFlags_RGB = ImGuiColorEditFlags_.ImGuiColorEditFlags_RGB;
alias ImGuiColorEditFlags_HSV = ImGuiColorEditFlags_.ImGuiColorEditFlags_HSV;
alias ImGuiColorEditFlags_HEX = ImGuiColorEditFlags_.ImGuiColorEditFlags_HEX;

enum ImGuiSliderFlags_
{
    ImGuiSliderFlags_None = 0, 
    ImGuiSliderFlags_AlwaysClamp = 16, 
    ImGuiSliderFlags_Logarithmic = 32, 
    ImGuiSliderFlags_NoRoundToFormat = 64, 
    ImGuiSliderFlags_NoInput = 128, 
    ImGuiSliderFlags_InvalidMask_ = 1879048207, 
    ImGuiSliderFlags_ClampOnInput = 16, 
}

alias ImGuiSliderFlags_None = ImGuiSliderFlags_.ImGuiSliderFlags_None;
alias ImGuiSliderFlags_AlwaysClamp = ImGuiSliderFlags_.ImGuiSliderFlags_AlwaysClamp;
alias ImGuiSliderFlags_Logarithmic = ImGuiSliderFlags_.ImGuiSliderFlags_Logarithmic;
alias ImGuiSliderFlags_NoRoundToFormat = ImGuiSliderFlags_.ImGuiSliderFlags_NoRoundToFormat;
alias ImGuiSliderFlags_NoInput = ImGuiSliderFlags_.ImGuiSliderFlags_NoInput;
alias ImGuiSliderFlags_InvalidMask_ = ImGuiSliderFlags_.ImGuiSliderFlags_InvalidMask_;
alias ImGuiSliderFlags_ClampOnInput = ImGuiSliderFlags_.ImGuiSliderFlags_ClampOnInput;

enum ImGuiMouseButton_
{
    ImGuiMouseButton_Left = 0, 
    ImGuiMouseButton_Right = 1, 
    ImGuiMouseButton_Middle = 2, 
    ImGuiMouseButton_COUNT = 5, 
}

alias ImGuiMouseButton_Left = ImGuiMouseButton_.ImGuiMouseButton_Left;
alias ImGuiMouseButton_Right = ImGuiMouseButton_.ImGuiMouseButton_Right;
alias ImGuiMouseButton_Middle = ImGuiMouseButton_.ImGuiMouseButton_Middle;
alias ImGuiMouseButton_COUNT = ImGuiMouseButton_.ImGuiMouseButton_COUNT;

enum ImGuiMouseCursor_
{
    ImGuiMouseCursor_None = -1, 
    ImGuiMouseCursor_Arrow = 0, 
    ImGuiMouseCursor_TextInput = 1, 
    ImGuiMouseCursor_ResizeAll = 2, 
    ImGuiMouseCursor_ResizeNS = 3, 
    ImGuiMouseCursor_ResizeEW = 4, 
    ImGuiMouseCursor_ResizeNESW = 5, 
    ImGuiMouseCursor_ResizeNWSE = 6, 
    ImGuiMouseCursor_Hand = 7, 
    ImGuiMouseCursor_NotAllowed = 8, 
    ImGuiMouseCursor_COUNT = 9, 
}

alias ImGuiMouseCursor_None = ImGuiMouseCursor_.ImGuiMouseCursor_None;
alias ImGuiMouseCursor_Arrow = ImGuiMouseCursor_.ImGuiMouseCursor_Arrow;
alias ImGuiMouseCursor_TextInput = ImGuiMouseCursor_.ImGuiMouseCursor_TextInput;
alias ImGuiMouseCursor_ResizeAll = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeAll;
alias ImGuiMouseCursor_ResizeNS = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNS;
alias ImGuiMouseCursor_ResizeEW = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeEW;
alias ImGuiMouseCursor_ResizeNESW = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNESW;
alias ImGuiMouseCursor_ResizeNWSE = ImGuiMouseCursor_.ImGuiMouseCursor_ResizeNWSE;
alias ImGuiMouseCursor_Hand = ImGuiMouseCursor_.ImGuiMouseCursor_Hand;
alias ImGuiMouseCursor_NotAllowed = ImGuiMouseCursor_.ImGuiMouseCursor_NotAllowed;
alias ImGuiMouseCursor_COUNT = ImGuiMouseCursor_.ImGuiMouseCursor_COUNT;

enum ImGuiCond_
{
    ImGuiCond_None = 0, 
    ImGuiCond_Always = 1, 
    ImGuiCond_Once = 2, 
    ImGuiCond_FirstUseEver = 4, 
    ImGuiCond_Appearing = 8, 
}

alias ImGuiCond_None = ImGuiCond_.ImGuiCond_None;
alias ImGuiCond_Always = ImGuiCond_.ImGuiCond_Always;
alias ImGuiCond_Once = ImGuiCond_.ImGuiCond_Once;
alias ImGuiCond_FirstUseEver = ImGuiCond_.ImGuiCond_FirstUseEver;
alias ImGuiCond_Appearing = ImGuiCond_.ImGuiCond_Appearing;

extern(C++)
@cppclasssize(1) align(1)
struct ImNewWrapper
{


}
extern(C++)
void IM_DELETE(T)(T* p){
if (p) {
destroy(p);
MemFree(p);
}

}

extern(C++)
struct ImVector(T)
{


    alias value_type = T;

    alias iterator = value_type*;

    alias const_iterator = const(value_type)*;

    @cppsize(4) public int Size;
    @cppsize(4) public int Capacity;
    @cppsize(0) public T* Data;
    // /* inline */ public this()//{
    //Size = Capacity = 0;
    //Data = null;
    //}

    public final void _default_ctor() {
    Size = Capacity = 0;
    Data = null;
    }

    // copy ctor
    /* inline */ public this(ref const(ImVector!(T)) src){
    Size = Capacity = 0;
    Data = null;
    opAssign(src);
    }

    // /* inline */ public ref ImVector!(T) opAssign(ref const(ImVector!(T)) src)//{
    //clear();
    //resize(src.Size);
    //memcpy(Data, src.Data, cast(size_t)Size * (T).sizeof);
    //return this;
    //}

    /* inline */ public ~this(){
    if (Data)
    MemFree(Data);
    
    }

    /* inline */ public bool empty() const {
    return Size == 0;
    }

    /* inline */ public int size() const {
    return Size;
    }

    /* inline */ public int size_in_bytes() const {
    return Size * cast(int)(T).sizeof;
    }

    /* inline */ public int max_size() const {
    return 2147483647 / cast(int)(T).sizeof;
    }

    /* inline */ public int capacity() const {
    return Capacity;
    }

    /* inline */ public ref T opIndex(int i){
    assert(!!(i >= 0 && i < Size), "i >= 0 && i < Size");
    return Data[i];
    }

    /* inline */ public ref const(T) opIndex(int i) const {
    assert(!!(i >= 0 && i < Size), "i >= 0 && i < Size");
    return Data[i];
    }

    /* inline */ public void clear(){
    if (Data) {
    Size = Capacity = 0;
    MemFree(Data);
    Data = null;
    }
    
    }

    /* inline */ public T* begin(){
    return Data;
    }

    /* inline */ public const(T)* begin() const {
    return Data;
    }

    /* inline */ public T* end(){
    return Data + Size;
    }

    /* inline */ public const(T)* end() const {
    return Data + Size;
    }

    /* inline */ public ref T front(){
    assert(!!(Size > 0), "Size > 0");
    return Data[0];
    }

    /* inline */ public ref const(T) front() const {
    assert(!!(Size > 0), "Size > 0");
    return Data[0];
    }

    /* inline */ public ref T back(){
    assert(!!(Size > 0), "Size > 0");
    return Data[Size - 1];
    }

    /* inline */ public ref const(T) back() const {
    assert(!!(Size > 0), "Size > 0");
    return Data[Size - 1];
    }

    /* inline */ public void swap(ref ImVector!(T) rhs){
    int rhs_size = rhs.Size;
    rhs.Size = Size;
    Size = rhs_size;
    int rhs_cap = rhs.Capacity;
    rhs.Capacity = Capacity;
    Capacity = rhs_cap;
    T* rhs_data = rhs.Data;
    rhs.Data = Data;
    Data = rhs_data;
    }

    /* inline */ public int _grow_capacity(int sz) const {
    int new_capacity = Capacity ? (Capacity + Capacity / 2) : 8;
    return new_capacity > sz ? new_capacity : sz;
    }

    /* inline */ public void resize(int new_size){
    if (new_size > Capacity)
    reserve(_grow_capacity(new_size));
    
    Size = new_size;
    }

    /* inline */ public void resize(int new_size, ref const(T) v){
    if (new_size > Capacity)
    reserve(_grow_capacity(new_size));
    
    if (new_size > Size)
    for (int n = Size; n < new_size; n++) 
    memcpy(&Data[n], &v,  (v).sizeof);
    Size = new_size;
    }

    /* inline */ public void shrink(int new_size){
    assert(!!(new_size <= Size), "new_size <= Size");
    Size = new_size;
    }

    /* inline */ public void reserve(int new_capacity){
    if (new_capacity <= Capacity)
    return;
    T* new_data = cast(T*)MemAlloc(cast(size_t)new_capacity * (T).sizeof);
    if (Data) {
    memcpy(new_data, Data, cast(size_t)Size * (T).sizeof);
    MemFree(Data);
    }
    
    Data = new_data;
    Capacity = new_capacity;
    }

    /* inline */ public void push_back(ref const(T) v){
    if (Size == Capacity)
    reserve(_grow_capacity(Size + 1));
    
    memcpy(&Data[Size], &v,  (v).sizeof);
    Size++;
    }

    /* inline */ public void pop_back(){
    assert(!!(Size > 0), "Size > 0");
    Size--;
    }

    /* inline */ public void push_front(ref const(T) v){
    if (Size == 0)
    push_back(v);
    else
    insert(Data, v);
    
    }

    /* inline */ public T* erase(const(T)* it){
    assert(!!(it >= Data && it < Data + Size), "it >= Data && it < Data + Size");
    ptrdiff_t off = it - Data;
    memmove(Data + off, Data + off + 1, (cast(size_t)Size - cast(size_t)off - 1) * (T).sizeof);
    Size--;
    return Data + off;
    }

    /* inline */ public T* erase(const(T)* it, const(T)* it_last){
    assert(!!(it >= Data && it < Data + Size && it_last > it && it_last <= Data + Size), "it >= Data && it < Data + Size && it_last > it && it_last <= Data + Size");
    ptrdiff_t count = it_last - it;
    ptrdiff_t off = it - Data;
    memmove(Data + off, Data + off + count, (cast(size_t)Size - cast(size_t)off - count) * (T).sizeof);
    Size -= cast(int)count;
    return Data + off;
    }

    /* inline */ public T* erase_unsorted(const(T)* it){
    assert(!!(it >= Data && it < Data + Size), "it >= Data && it < Data + Size");
    ptrdiff_t off = it - Data;
    if (it < Data + Size - 1)
    memcpy(Data + off, Data + Size - 1, (T).sizeof);
    
    Size--;
    return Data + off;
    }

    /* inline */ public T* insert(const(T)* it, ref const(T) v){
    assert(!!(it >= Data && it <= Data + Size), "it >= Data && it <= Data + Size");
    ptrdiff_t off = it - Data;
    if (Size == Capacity)
    reserve(_grow_capacity(Size + 1));
    
    if (off < cast(int)Size)
    memmove(Data + off + 1, Data + off, (cast(size_t)Size - cast(size_t)off) * (T).sizeof);
    
    memcpy(&Data[off], &v,  (v).sizeof);
    Size++;
    return Data + off;
    }

    /* inline */ public bool contains(ref const(T) v) const {
    const(T)* data = Data;
    const(T)* data_end = Data + Size;
    while (data < data_end)
    if (*data++ == v)
    return true;
    return false;
    }

    /* inline */ public T* find(ref const(T) v){
    T* data = Data;
    const(T)* data_end = Data + Size;
    while (data < data_end)
    if (*data == v)
    break;
    else
    ++data;
    
    return data;
    }

    /* inline */ public const(T)* find(ref const(T) v) const {
    const(T)* data = Data;
    const(T)* data_end = Data + Size;
    while (data < data_end)
    if (*data == v)
    break;
    else
    ++data;
    
    return data;
    }

    /* inline */ public bool find_erase(ref const(T) v){
    const(T)* it = find(v);
    if (it < Data + Size) {
    erase(it);
    return true;
    }
    
    return false;
    }

    /* inline */ public bool find_erase_unsorted(ref const(T) v){
    const(T)* it = find(v);
    if (it < Data + Size) {
    erase_unsorted(it);
    return true;
    }
    
    return false;
    }

    /* inline */ public int index_from_ptr(const(T)* it) const {
    assert(!!(it >= Data && it < Data + Size), "it >= Data && it < Data + Size");
    ptrdiff_t off = it - Data;
    return cast(int)off;
    }

}
extern(C++)
@cppclasssize(1044) align(4)
struct ImGuiStyle
{


    @cppsize(4) public float Alpha;
    @cppsize(8) public ImVec2 WindowPadding;
    @cppsize(4) public float WindowRounding;
    @cppsize(4) public float WindowBorderSize;
    @cppsize(8) public ImVec2 WindowMinSize;
    @cppsize(8) public ImVec2 WindowTitleAlign;
    @cppsize(4) public ImGuiDir WindowMenuButtonPosition;
    @cppsize(4) public float ChildRounding;
    @cppsize(4) public float ChildBorderSize;
    @cppsize(4) public float PopupRounding;
    @cppsize(4) public float PopupBorderSize;
    @cppsize(8) public ImVec2 FramePadding;
    @cppsize(4) public float FrameRounding;
    @cppsize(4) public float FrameBorderSize;
    @cppsize(8) public ImVec2 ItemSpacing;
    @cppsize(8) public ImVec2 ItemInnerSpacing;
    @cppsize(8) public ImVec2 CellPadding;
    @cppsize(8) public ImVec2 TouchExtraPadding;
    @cppsize(4) public float IndentSpacing;
    @cppsize(4) public float ColumnsMinSpacing;
    @cppsize(4) public float ScrollbarSize;
    @cppsize(4) public float ScrollbarRounding;
    @cppsize(4) public float GrabMinSize;
    @cppsize(4) public float GrabRounding;
    @cppsize(4) public float LogSliderDeadzone;
    @cppsize(4) public float TabRounding;
    @cppsize(4) public float TabBorderSize;
    @cppsize(4) public float TabMinWidthForCloseButton;
    @cppsize(4) public ImGuiDir ColorButtonPosition;
    @cppsize(8) public ImVec2 ButtonTextAlign;
    @cppsize(8) public ImVec2 SelectableTextAlign;
    @cppsize(8) public ImVec2 DisplayWindowPadding;
    @cppsize(8) public ImVec2 DisplaySafeAreaPadding;
    @cppsize(4) public float MouseCursorScale;
    @cppsize(1) public bool AntiAliasedLines;
    @cppsize(1) public bool AntiAliasedLinesUseTex;
    @cppsize(1) public bool AntiAliasedFill;
    @cppsize(4) public float CurveTessellationTol;
    @cppsize(4) public float CircleTessellationMaxError;
    @cppsize(848) public ImVec4[53] Colors;
    // public this();

    pragma (mangle, "??0ImGuiStyle@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

    public void ScaleAllSizes(float scale_factor);

}
extern(C++)
@cppclasssize(5464) align(8)
struct ImGuiIO
{


    @cppsize(4) public ImGuiConfigFlags ConfigFlags;
    @cppsize(4) public ImGuiBackendFlags BackendFlags;
    @cppsize(8) public ImVec2 DisplaySize;
    @cppsize(4) public float DeltaTime;
    @cppsize(4) public float IniSavingRate;
    @cppsize(8) public const(char)* IniFilename;
    @cppsize(8) public const(char)* LogFilename;
    @cppsize(4) public float MouseDoubleClickTime;
    @cppsize(4) public float MouseDoubleClickMaxDist;
    @cppsize(4) public float MouseDragThreshold;
    @cppsize(88) public int[22] KeyMap;
    @cppsize(4) public float KeyRepeatDelay;
    @cppsize(4) public float KeyRepeatRate;
    @cppsize(8) public void* UserData;
    @cppsize(8) public ImFontAtlas* Fonts;
    @cppsize(4) public float FontGlobalScale;
    @cppsize(1) public bool FontAllowUserScaling;
    @cppsize(8) public ImFont* FontDefault;
    @cppsize(8) public ImVec2 DisplayFramebufferScale;
    @cppsize(1) public bool MouseDrawCursor;
    @cppsize(1) public bool ConfigMacOSXBehaviors;
    @cppsize(1) public bool ConfigInputTextCursorBlink;
    @cppsize(1) public bool ConfigDragClickToInputText;
    @cppsize(1) public bool ConfigWindowsResizeFromEdges;
    @cppsize(1) public bool ConfigWindowsMoveFromTitleBarOnly;
    @cppsize(4) public float ConfigMemoryCompactTimer;
    @cppsize(8) public const(char)* BackendPlatformName;
    @cppsize(8) public const(char)* BackendRendererName;
    @cppsize(8) public void* BackendPlatformUserData;
    @cppsize(8) public void* BackendRendererUserData;
    @cppsize(8) public void* BackendLanguageUserData;
    @cppsize(8) public const(char)* function(void*) GetClipboardTextFn;
    @cppsize(8) public void function(void*, const(char)*) SetClipboardTextFn;
    @cppsize(8) public void* ClipboardUserData;
    @cppsize(8) public void function(int, int) ImeSetInputScreenPosFn;
    @cppsize(8) public void* ImeWindowHandle;
    @cppsize(8) public ImVec2 MousePos;
    @cppsize(5) public bool[5] MouseDown;
    @cppsize(4) public float MouseWheel;
    @cppsize(4) public float MouseWheelH;
    @cppsize(1) public bool KeyCtrl;
    @cppsize(1) public bool KeyShift;
    @cppsize(1) public bool KeyAlt;
    @cppsize(1) public bool KeySuper;
    @cppsize(512) public bool[512] KeysDown;
    @cppsize(84) public float[21] NavInputs;
    @cppsize(1) public bool WantCaptureMouse;
    @cppsize(1) public bool WantCaptureKeyboard;
    @cppsize(1) public bool WantTextInput;
    @cppsize(1) public bool WantSetMousePos;
    @cppsize(1) public bool WantSaveIniSettings;
    @cppsize(1) public bool NavActive;
    @cppsize(1) public bool NavVisible;
    @cppsize(4) public float Framerate;
    @cppsize(4) public int MetricsRenderVertices;
    @cppsize(4) public int MetricsRenderIndices;
    @cppsize(4) public int MetricsRenderWindows;
    @cppsize(4) public int MetricsActiveWindows;
    @cppsize(4) public int MetricsActiveAllocations;
    @cppsize(8) public ImVec2 MouseDelta;
    @cppsize(4) public ImGuiKeyModFlags KeyMods;
    @cppsize(8) public ImVec2 MousePosPrev;
    @cppsize(40) public ImVec2[5] MouseClickedPos;
    @cppsize(40) public double[5] MouseClickedTime;
    @cppsize(5) public bool[5] MouseClicked;
    @cppsize(5) public bool[5] MouseDoubleClicked;
    @cppsize(5) public bool[5] MouseReleased;
    @cppsize(5) public bool[5] MouseDownOwned;
    @cppsize(5) public bool[5] MouseDownWasDoubleClick;
    @cppsize(20) public float[5] MouseDownDuration;
    @cppsize(20) public float[5] MouseDownDurationPrev;
    @cppsize(40) public ImVec2[5] MouseDragMaxDistanceAbs;
    @cppsize(20) public float[5] MouseDragMaxDistanceSqr;
    @cppsize(2048) public float[512] KeysDownDuration;
    @cppsize(2048) public float[512] KeysDownDurationPrev;
    @cppsize(84) public float[21] NavInputsDownDuration;
    @cppsize(84) public float[21] NavInputsDownDurationPrev;
    @cppsize(4) public float PenPressure;
    @cppsize(2) public ImWchar16 InputQueueSurrogate;
    @cppsize(16) public ImVector!(ImWchar) InputQueueCharacters;
    public void AddInputCharacter(uint c);

    public void AddInputCharacterUTF16(ImWchar16 c);

    public void AddInputCharactersUTF8(const(char)* str);

    public void ClearInputCharacters();

    // public this();

    pragma (mangle, "??0ImGuiIO@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

}
extern(C++)
@cppclasssize(56) align(8)
struct ImGuiInputTextCallbackData
{


    @cppsize(4) public ImGuiInputTextFlags EventFlag;
    @cppsize(4) public ImGuiInputTextFlags Flags;
    @cppsize(8) public void* UserData;
    @cppsize(2) public ImWchar EventChar;
    @cppsize(4) public ImGuiKey EventKey;
    @cppsize(8) public char* Buf;
    @cppsize(4) public int BufTextLen;
    @cppsize(4) public int BufSize;
    @cppsize(1) public bool BufDirty;
    @cppsize(4) public int CursorPos;
    @cppsize(4) public int SelectionStart;
    @cppsize(4) public int SelectionEnd;
    // public this();

    pragma (mangle, "??0ImGuiInputTextCallbackData@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

    public void DeleteChars(int pos, int bytes_count);

    public void InsertChars(int pos, const(char)* text, const(char)* text_end = null);

    /* inline */ public void SelectAll(){
    SelectionStart = 0;
    SelectionEnd = BufTextLen;
    }

    /* inline */ public void ClearSelection(){
    SelectionStart = SelectionEnd = BufTextLen;
    }

    /* inline */ public bool HasSelection() const {
    return SelectionStart != SelectionEnd;
    }

}
extern(C++)
@cppclasssize(32) align(8)
struct ImGuiSizeCallbackData
{


    @cppsize(8) public void* UserData;
    @cppsize(8) public ImVec2 Pos;
    @cppsize(8) public ImVec2 CurrentSize;
    @cppsize(8) public ImVec2 DesiredSize;
}
extern(C++)
@cppclasssize(64) align(8)
struct ImGuiPayload
{


    @cppsize(8) public void* Data;
    @cppsize(4) public int DataSize;
    @cppsize(4) public ImGuiID SourceId;
    @cppsize(4) public ImGuiID SourceParentId;
    @cppsize(4) public int DataFrameCount;
    @cppsize(33) public char[33] DataType;
    @cppsize(1) public bool Preview;
    @cppsize(1) public bool Delivery;
    // /* inline */ public this()//{
    //Clear();
    //}

    public final void _default_ctor() {
    Clear();
    }

    /* inline */ public void Clear(){
    SourceId = SourceParentId = 0;
    Data = null;
    DataSize = 0;
    memset(DataType.ptr, 0,  (DataType).sizeof);
    DataFrameCount = -1;
    Preview = Delivery = false;
    }

    /* inline */ public bool IsDataType(const(char)* type) const {
    return DataFrameCount != -1 && strcmp(type, DataType.ptr) == 0;
    }

    /* inline */ public bool IsPreview() const {
    return Preview;
    }

    /* inline */ public bool IsDelivery() const {
    return Delivery;
    }

}
extern(C++)
@cppclasssize(12) align(4)
struct ImGuiTableColumnSortSpecs
{
align(4):


    @cppsize(4) public ImGuiID ColumnUserID;
    @cppsize(2) public ImS16 ColumnIndex;
    @cppsize(2) public ImS16 SortOrder;
    mixin(bitfields!(
        ImGuiSortDirection, "SortDirection", 8));
    // /* inline */ public this()//{
    //memset(&this, 0,  typeof(this).sizeof);
    //}

    public final void _default_ctor() {
    memset(&this, 0,  typeof(this).sizeof);
    }

}
extern(C++)
@cppclasssize(16) align(8)
struct ImGuiTableSortSpecs
{


    @cppsize(8) public const(ImGuiTableColumnSortSpecs)* Specs;
    @cppsize(4) public int SpecsCount;
    @cppsize(1) public bool SpecsDirty;
    // /* inline */ public this()//{
    //memset(&this, 0,  typeof(this).sizeof);
    //}

    public final void _default_ctor() {
    memset(&this, 0,  typeof(this).sizeof);
    }

}
extern(C++)
@cppclasssize(4) align(4)
struct ImGuiOnceUponAFrame
{


    @cppsize(4) public int RefFrame;
    // /* inline */ public this()//{
    //RefFrame = -1;
    //}

    public final void _default_ctor() {
    RefFrame = -1;
    }

    /* inline */ public bool opCast(Ty:bool)() const {
    int current_frame = GetFrameCount();
    if (RefFrame == current_frame)
    return false;
    RefFrame = current_frame;
    return true;
    }

}
extern(C++)
@cppclasssize(280) align(8)
struct ImGuiTextFilter
{


    extern(C++)
    @cppclasssize(16) align(8)
    struct ImGuiTextRange
    {


        @cppsize(8) public const(char)* b;
        @cppsize(8) public const(char)* e;
        // /* inline */ public this()//{
        //b = e = null;
        //}

        public final void _default_ctor() {
        b = e = null;
        }

        /* inline */ public this(const(char)* _b, const(char)* _e){
        b = _b;
        e = _e;
        }

        /* inline */ public bool empty() const {
        return b == e;
        }

        public void split(char separator, ImVector!(ImGuiTextRange)* out_) const ;

    }
    @cppsize(256) public char[256] InputBuf;
    @cppsize(16) public ImVector!(ImGuiTextRange) Filters;
    @cppsize(4) public int CountGrep;
    // public this(const(char)* default_filter = "");

    pragma (mangle, "??0ImGuiTextFilter@@QEAA@PEBD@Z")
    extern(C++) public final void _default_ctor(const(char)* default_filter = "");

    public bool Draw(const(char)* label = "Filter (inc,-exc)", float width = 0f);

    public bool PassFilter(const(char)* text, const(char)* text_end = null) const ;

    public void Build();

    /* inline */ public void Clear(){
    InputBuf[0] = 0;
    Build();
    }

    /* inline */ public bool IsActive() const {
    return !Filters.empty();
    }

}
extern(C++)
@cppclasssize(16) align(8)
struct ImGuiTextBuffer
{


    __gshared static extern char[1] EmptyString;
    @cppsize(16) public ImVector!(char) Buf;
    // /* inline */ public this() {} 

    public final void _default_ctor()  {} 

    /* inline */ public char opIndex(int i) const {
    assert(!!(Buf.Data != null), "Buf.Data != 0");
    return Buf.Data[i];
    }

    /* inline */ public const(char)* begin() const {
    return Buf.Data ? &Buf.front() : EmptyString.ptr;
    }

    /* inline */ public const(char)* end() const {
    return Buf.Data ? &Buf.back() : EmptyString.ptr;
    }

    /* inline */ public int size() const {
    return Buf.Size ? Buf.Size - 1 : 0;
    }

    /* inline */ public bool empty() const {
    return Buf.Size <= 1;
    }

    /* inline */ public void clear(){
    Buf.clear();
    }

    /* inline */ public void reserve(int capacity){
    Buf.reserve(capacity);
    }

    /* inline */ public const(char)* c_str() const {
    return Buf.Data ? Buf.Data : EmptyString.ptr;
    }

    public void append(const(char)* str, const(char)* str_end = null);

    public void appendf(const(char)* fmt, ...);

    public void appendfv(const(char)* fmt, char* args);

}
extern(C++)
@cppclasssize(16) align(8)
struct ImGuiStorage
{


    extern(C++)
    @cppclasssize(16) align(8)
    struct ImGuiStoragePair
    {


        extern(C++)
        @cppclasssize(8) align(8)
        union _anon1
        {
            @cppsize(4) public int val_i;
            @cppsize(4) public float val_f;
            @cppsize(8) public void* val_p;
        }


        @cppsize(4) public ImGuiID key;
        @cppsize(8) public _anon1 a1_;
        /* inline */ public this(ImGuiID _key, int _val_i){
        key = _key;
        a1_.val_i = _val_i;
        }

        /* inline */ public this(ImGuiID _key, float _val_f){
        key = _key;
        a1_.val_f = _val_f;
        }

        /* inline */ public this(ImGuiID _key, void* _val_p){
        key = _key;
        a1_.val_p = _val_p;
        }

    }
    @cppsize(16) public ImVector!(ImGuiStoragePair) Data;
    /* inline */ public void Clear(){
    Data.clear();
    }

    public int GetInt(ImGuiID key, int default_val = 0) const ;

    public void SetInt(ImGuiID key, int val);

    public bool GetBool(ImGuiID key, bool default_val = false) const ;

    public void SetBool(ImGuiID key, bool val);

    public float GetFloat(ImGuiID key, float default_val = 0f) const ;

    public void SetFloat(ImGuiID key, float val);

    public void* GetVoidPtr(ImGuiID key) const ;

    public void SetVoidPtr(ImGuiID key, void* val);

    public int* GetIntRef(ImGuiID key, int default_val = 0);

    public bool* GetBoolRef(ImGuiID key, bool default_val = false);

    public float* GetFloatRef(ImGuiID key, float default_val = 0f);

    public void** GetVoidPtrRef(ImGuiID key, void* default_val = null);

    public void SetAllInt(int val);

    public void BuildSortByKey();

}
extern(C++)
@cppclasssize(28) align(4)
struct ImGuiListClipper
{


    @cppsize(4) public int DisplayStart;
    @cppsize(4) public int DisplayEnd;
    @cppsize(4) public int ItemsCount;
    @cppsize(4) public int StepNo;
    @cppsize(4) public int ItemsFrozen;
    @cppsize(4) public float ItemsHeight;
    @cppsize(4) public float StartPosY;
    // public this();

    pragma (mangle, "??0ImGuiListClipper@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

    public ~this();

    public void Begin(int items_count, float items_height = -1f);

    public void End();

    public bool Step();

    /* inline */ public this(int items_count, float items_height = -1f){
    memset(&this, 0,  typeof(this).sizeof);
    ItemsCount = -1;
    Begin(items_count, items_height);
    }

}
extern(C++)
@cppclasssize(16) align(4)
struct ImColor
{


    @cppsize(16) public ImVec4 Value;
    // /* inline */ public this()//{
    //Value.x = Value.y = Value.z = Value.w = 0f;
    //}

    public final void _default_ctor() {
    Value.x = Value.y = Value.z = Value.w = 0f;
    }

    /* inline */ public this(int r, int g, int b, int a = 255){
    float sc = 1f / 255f;
    Value.x = cast(float)r * sc;
    Value.y = cast(float)g * sc;
    Value.z = cast(float)b * sc;
    Value.w = cast(float)a * sc;
    }

    /* inline */ public this(ImU32 rgba){
    float sc = 1f / 255f;
    Value.x = cast(float)((rgba >> 0) & 255) * sc;
    Value.y = cast(float)((rgba >> 8) & 255) * sc;
    Value.z = cast(float)((rgba >> 16) & 255) * sc;
    Value.w = cast(float)((rgba >> 24) & 255) * sc;
    }

    /* inline */ public this(float r, float g, float b, float a = 1f){
    Value.x = r;
    Value.y = g;
    Value.z = b;
    Value.w = a;
    }

    /* inline */ public this(ref const(ImVec4) col){
    Value = col;
    }

    /* inline */ public ImU32 opCast(Ty:ImU32)() const {
    return ColorConvertFloat4ToU32(Value);
    }

    /* inline */ public ImVec4 opCast(Ty:ImVec4)() const {
    return Value;
    }

    /* inline */ public void SetHSV(float h, float s, float v, float a = 1f){
    ColorConvertHSVtoRGB(h, s, v, Value.x, Value.y, Value.z);
    Value.w = a;
    }

    /* inline */ public static ImColor HSV(float h, float s, float v, float a = 1f){
    float r; float g; float b;
    ColorConvertHSVtoRGB(h, s, v, r, g, b);
    return ImColor(r, g, b, a);
    }

}
alias ImDrawCallback = extern(C++) void function(const(ImDrawList)*, const(ImDrawCmd)*);

extern(C++)
@cppclasssize(56) align(8)
struct ImDrawCmd
{


    @cppsize(16) public ImVec4 ClipRect;
    @cppsize(8) public void* TextureId;
    @cppsize(4) public uint VtxOffset;
    @cppsize(4) public uint IdxOffset;
    @cppsize(4) public uint ElemCount;
    @cppsize(8) public void function(const(ImDrawList)*, const(ImDrawCmd)*) UserCallback;
    @cppsize(8) public void* UserCallbackData;
    // /* inline */ public this()//{
    //memset(&this, 0,  typeof(this).sizeof);
    //}

    public final void _default_ctor() {
    memset(&this, 0,  typeof(this).sizeof);
    }

    /* inline */ public void* GetTexID() const {
    return cast(void*) TextureId;
    }

}
alias ImDrawIdx = ushort;

extern(C++)
@cppclasssize(20) align(4)
struct ImDrawVert
{


    @cppsize(8) public ImVec2 pos;
    @cppsize(8) public ImVec2 uv;
    @cppsize(4) public ImU32 col;
}
extern(C++)
@cppclasssize(32) align(8)
struct ImDrawCmdHeader
{


    @cppsize(16) public ImVec4 ClipRect;
    @cppsize(8) public void* TextureId;
    @cppsize(4) public uint VtxOffset;
}
extern(C++)
@cppclasssize(32) align(8)
struct ImDrawChannel
{


    @cppsize(16) public ImVector!(ImDrawCmd) _CmdBuffer;
    @cppsize(16) public ImVector!(ImDrawIdx) _IdxBuffer;
}
extern(C++)
@cppclasssize(24) align(8)
struct ImDrawListSplitter
{


    @cppsize(4) public int _Current;
    @cppsize(4) public int _Count;
    @cppsize(16) public ImVector!(ImDrawChannel) _Channels;
    // /* inline */ public this()//{
    //memset(&this, 0,  typeof(this).sizeof);
    //}

    public final void _default_ctor() {
    memset(&this, 0,  typeof(this).sizeof);
    }

    /* inline */ public ~this(){
    ClearFreeMemory();
    }

    /* inline */ public void Clear(){
    _Current = 0;
    _Count = 1;
    }

    public void ClearFreeMemory();

    public void Split(ImDrawList* draw_list, int count);

    public void Merge(ImDrawList* draw_list);

    public void SetCurrentChannel(ImDrawList* draw_list, int channel_idx);

}
enum ImDrawFlags_
{
    ImDrawFlags_None = 0, 
    ImDrawFlags_Closed = 1, 
    ImDrawFlags_RoundCornersTopLeft = 16, 
    ImDrawFlags_RoundCornersTopRight = 32, 
    ImDrawFlags_RoundCornersBottomLeft = 64, 
    ImDrawFlags_RoundCornersBottomRight = 128, 
    ImDrawFlags_RoundCornersNone = 256, 
    ImDrawFlags_RoundCornersTop = 48, 
    ImDrawFlags_RoundCornersBottom = 192, 
    ImDrawFlags_RoundCornersLeft = 80, 
    ImDrawFlags_RoundCornersRight = 160, 
    ImDrawFlags_RoundCornersAll = 240, 
    ImDrawFlags_RoundCornersDefault_ = 240, 
    ImDrawFlags_RoundCornersMask_ = 496, 
}

alias ImDrawFlags_None = ImDrawFlags_.ImDrawFlags_None;
alias ImDrawFlags_Closed = ImDrawFlags_.ImDrawFlags_Closed;
alias ImDrawFlags_RoundCornersTopLeft = ImDrawFlags_.ImDrawFlags_RoundCornersTopLeft;
alias ImDrawFlags_RoundCornersTopRight = ImDrawFlags_.ImDrawFlags_RoundCornersTopRight;
alias ImDrawFlags_RoundCornersBottomLeft = ImDrawFlags_.ImDrawFlags_RoundCornersBottomLeft;
alias ImDrawFlags_RoundCornersBottomRight = ImDrawFlags_.ImDrawFlags_RoundCornersBottomRight;
alias ImDrawFlags_RoundCornersNone = ImDrawFlags_.ImDrawFlags_RoundCornersNone;
alias ImDrawFlags_RoundCornersTop = ImDrawFlags_.ImDrawFlags_RoundCornersTop;
alias ImDrawFlags_RoundCornersBottom = ImDrawFlags_.ImDrawFlags_RoundCornersBottom;
alias ImDrawFlags_RoundCornersLeft = ImDrawFlags_.ImDrawFlags_RoundCornersLeft;
alias ImDrawFlags_RoundCornersRight = ImDrawFlags_.ImDrawFlags_RoundCornersRight;
alias ImDrawFlags_RoundCornersAll = ImDrawFlags_.ImDrawFlags_RoundCornersAll;
alias ImDrawFlags_RoundCornersDefault_ = ImDrawFlags_.ImDrawFlags_RoundCornersDefault_;
alias ImDrawFlags_RoundCornersMask_ = ImDrawFlags_.ImDrawFlags_RoundCornersMask_;

enum ImDrawListFlags_
{
    ImDrawListFlags_None = 0, 
    ImDrawListFlags_AntiAliasedLines = 1, 
    ImDrawListFlags_AntiAliasedLinesUseTex = 2, 
    ImDrawListFlags_AntiAliasedFill = 4, 
    ImDrawListFlags_AllowVtxOffset = 8, 
}

alias ImDrawListFlags_None = ImDrawListFlags_.ImDrawListFlags_None;
alias ImDrawListFlags_AntiAliasedLines = ImDrawListFlags_.ImDrawListFlags_AntiAliasedLines;
alias ImDrawListFlags_AntiAliasedLinesUseTex = ImDrawListFlags_.ImDrawListFlags_AntiAliasedLinesUseTex;
alias ImDrawListFlags_AntiAliasedFill = ImDrawListFlags_.ImDrawListFlags_AntiAliasedFill;
alias ImDrawListFlags_AllowVtxOffset = ImDrawListFlags_.ImDrawListFlags_AllowVtxOffset;

extern(C++)
@cppclasssize(200) align(8)
struct ImDrawList
{


    @cppsize(16) public ImVector!(ImDrawCmd) CmdBuffer;
    @cppsize(16) public ImVector!(ImDrawIdx) IdxBuffer;
    @cppsize(16) public ImVector!(ImDrawVert) VtxBuffer;
    @cppsize(4) public ImDrawListFlags Flags;
    @cppsize(4) public uint _VtxCurrentIdx;
    @cppsize(8) public const(ImDrawListSharedData)* _Data;
    @cppsize(8) public const(char)* _OwnerName;
    @cppsize(8) public ImDrawVert* _VtxWritePtr;
    @cppsize(8) public ImDrawIdx* _IdxWritePtr;
    @cppsize(16) public ImVector!(ImVec4) _ClipRectStack;
    @cppsize(16) public ImVector!(void*) _TextureIdStack;
    @cppsize(16) public ImVector!(ImVec2) _Path;
    @cppsize(32) public ImDrawCmdHeader _CmdHeader;
    @cppsize(24) public ImDrawListSplitter _Splitter;
    @cppsize(4) public float _FringeScale;
    /* inline */ public this(const(ImDrawListSharedData)* shared_data){
    memset(&this, 0,  typeof(this).sizeof);
    _Data = shared_data;
    }

    /* inline */ public ~this(){
    _ClearFreeMemory();
    }

    public void PushClipRect(ImVec2 clip_rect_min, ImVec2 clip_rect_max, bool intersect_with_current_clip_rect = false);

    public void PushClipRectFullScreen();

    public void PopClipRect();

    public void PushTextureID(void* texture_id);

    public void PopTextureID();

    /* inline */ public ImVec2 GetClipRectMin() const {
    ref const(ImVec4) cr() { return _ClipRectStack.back(); }
    return ImVec2(cr.x, cr.y);
    }

    /* inline */ public ImVec2 GetClipRectMax() const {
    ref const(ImVec4) cr() { return _ClipRectStack.back(); }
    return ImVec2(cr.z, cr.w);
    }

    public void AddLine(ref const(ImVec2) p1, ref const(ImVec2) p2, ImU32 col, float thickness = 1f);

    public void AddRect(ref const(ImVec2) p_min, ref const(ImVec2) p_max, ImU32 col, float rounding = 0f, ImDrawFlags flags = 0, float thickness = 1f);

    public void AddRectFilled(ref const(ImVec2) p_min, ref const(ImVec2) p_max, ImU32 col, float rounding = 0f, ImDrawFlags flags = 0);

    public void AddRectFilledMultiColor(ref const(ImVec2) p_min, ref const(ImVec2) p_max, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left);

    public void AddQuad(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, ImU32 col, float thickness = 1f);

    public void AddQuadFilled(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, ImU32 col);

    public void AddTriangle(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ImU32 col, float thickness = 1f);

    public void AddTriangleFilled(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ImU32 col);

    public void AddCircle(ref const(ImVec2) center, float radius, ImU32 col, int num_segments = 0, float thickness = 1f);

    public void AddCircleFilled(ref const(ImVec2) center, float radius, ImU32 col, int num_segments = 0);

    public void AddNgon(ref const(ImVec2) center, float radius, ImU32 col, int num_segments, float thickness = 1f);

    public void AddNgonFilled(ref const(ImVec2) center, float radius, ImU32 col, int num_segments);

    public void AddText(ref const(ImVec2) pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null);

    public void AddText(const(ImFont)* font, float font_size, ref const(ImVec2) pos, ImU32 col, const(char)* text_begin, const(char)* text_end = null, float wrap_width = 0f, const(ImVec4)* cpu_fine_clip_rect = null);

    public void AddPolyline(const(ImVec2)* points, int num_points, ImU32 col, ImDrawFlags flags, float thickness);

    public void AddConvexPolyFilled(const(ImVec2)* points, int num_points, ImU32 col);

    public void AddBezierCubic(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, ImU32 col, float thickness, int num_segments = 0);

    public void AddBezierQuadratic(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ImU32 col, float thickness, int num_segments = 0);

    public void AddImage(void* user_texture_id, ref const(ImVec2) p_min, ref const(ImVec2) p_max, ref const(ImVec2) uv_min = ImVec2(0, 0).byRef , ref const(ImVec2) uv_max = ImVec2(1, 1).byRef , ImU32 col = ((cast(ImU32)(255) << 24) | (cast(ImU32)(255) << 16) | (cast(ImU32)(255) << 8) | (cast(ImU32)(255) << 0)));

    public void AddImageQuad(void* user_texture_id, ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, ref const(ImVec2) uv1 = ImVec2(0, 0).byRef , ref const(ImVec2) uv2 = ImVec2(1, 0).byRef , ref const(ImVec2) uv3 = ImVec2(1, 1).byRef , ref const(ImVec2) uv4 = ImVec2(0, 1).byRef , ImU32 col = ((cast(ImU32)(255) << 24) | (cast(ImU32)(255) << 16) | (cast(ImU32)(255) << 8) | (cast(ImU32)(255) << 0)));

    public void AddImageRounded(void* user_texture_id, ref const(ImVec2) p_min, ref const(ImVec2) p_max, ref const(ImVec2) uv_min, ref const(ImVec2) uv_max, ImU32 col, float rounding, ImDrawFlags flags = 0);

    /* inline */ public void PathClear(){
    _Path.Size = 0;
    }

    /* inline */ public void PathLineTo(ref const(ImVec2) pos){
    _Path.push_back(pos);
    }

    /* inline */ public void PathLineToMergeDuplicate(ref const(ImVec2) pos){
    if (_Path.Size == 0 || memcmp(&_Path.Data[_Path.Size - 1], &pos, 8) != 0)
    _Path.push_back(pos);
    
    }

    /* inline */ public void PathFillConvex(ImU32 col){
    AddConvexPolyFilled(_Path.Data, _Path.Size, col);
    _Path.Size = 0;
    }

    /* inline */ public void PathStroke(ImU32 col, ImDrawFlags flags = 0, float thickness = 1f){
    AddPolyline(_Path.Data, _Path.Size, col, flags, thickness);
    _Path.Size = 0;
    }

    public void PathArcTo(ref const(ImVec2) center, float radius, float a_min, float a_max, int num_segments = 0);

    public void PathArcToFast(ref const(ImVec2) center, float radius, int a_min_of_12, int a_max_of_12);

    public void PathBezierCubicCurveTo(ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, int num_segments = 0);

    public void PathBezierQuadraticCurveTo(ref const(ImVec2) p2, ref const(ImVec2) p3, int num_segments = 0);

    public void PathRect(ref const(ImVec2) rect_min, ref const(ImVec2) rect_max, float rounding = 0f, ImDrawFlags flags = 0);

    public void AddCallback(void function(const(ImDrawList)*, const(ImDrawCmd)*) callback, void* callback_data);

    public void AddDrawCmd();

    public ImDrawList* CloneOutput() const ;

    /* inline */ public void ChannelsSplit(int count){
    _Splitter.Split(&this, count);
    }

    /* inline */ public void ChannelsMerge(){
    _Splitter.Merge(&this);
    }

    /* inline */ public void ChannelsSetCurrent(int n){
    _Splitter.SetCurrentChannel(&this, n);
    }

    public void PrimReserve(int idx_count, int vtx_count);

    public void PrimUnreserve(int idx_count, int vtx_count);

    public void PrimRect(ref const(ImVec2) a, ref const(ImVec2) b, ImU32 col);

    public void PrimRectUV(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) uv_a, ref const(ImVec2) uv_b, ImU32 col);

    public void PrimQuadUV(ref const(ImVec2) a, ref const(ImVec2) b, ref const(ImVec2) c, ref const(ImVec2) d, ref const(ImVec2) uv_a, ref const(ImVec2) uv_b, ref const(ImVec2) uv_c, ref const(ImVec2) uv_d, ImU32 col);

    /* inline */ public void PrimWriteVtx(ref const(ImVec2) pos, ref const(ImVec2) uv, ImU32 col){
    _VtxWritePtr.pos = pos;
    _VtxWritePtr.uv = uv;
    _VtxWritePtr.col = col;
    _VtxWritePtr++;
    _VtxCurrentIdx++;
    }

    /* inline */ public void PrimWriteIdx(ImDrawIdx idx){
    *_IdxWritePtr = idx;
    _IdxWritePtr++;
    }

    /* inline */ public void PrimVtx(ref const(ImVec2) pos, ref const(ImVec2) uv, ImU32 col){
    PrimWriteIdx(cast(ImDrawIdx)_VtxCurrentIdx);
    PrimWriteVtx(pos, uv, col);
    }

    /* inline */ public void AddBezierCurve(ref const(ImVec2) p1, ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, ImU32 col, float thickness, int num_segments = 0){
    AddBezierCubic(p1, p2, p3, p4, col, thickness, num_segments);
    }

    /* inline */ public void PathBezierCurveTo(ref const(ImVec2) p2, ref const(ImVec2) p3, ref const(ImVec2) p4, int num_segments = 0){
    PathBezierCubicCurveTo(p2, p3, p4, num_segments);
    }

    public void _ResetForNewFrame();

    public void _ClearFreeMemory();

    public void _PopUnusedDrawCmd();

    public void _OnChangedClipRect();

    public void _OnChangedTextureID();

    public void _OnChangedVtxOffset();

    public int _CalcCircleAutoSegmentCount(float radius) const ;

    public void _PathArcToFastEx(ref const(ImVec2) center, float radius, int a_min_sample, int a_max_sample, int a_step);

    public void _PathArcToN(ref const(ImVec2) center, float radius, float a_min, float a_max, int num_segments);

}
extern(C++)
@cppclasssize(48) align(8)
struct ImDrawData
{


    @cppsize(1) public bool Valid;
    @cppsize(4) public int CmdListsCount;
    @cppsize(4) public int TotalIdxCount;
    @cppsize(4) public int TotalVtxCount;
    @cppsize(8) public ImDrawList** CmdLists;
    @cppsize(8) public ImVec2 DisplayPos;
    @cppsize(8) public ImVec2 DisplaySize;
    @cppsize(8) public ImVec2 FramebufferScale;
    // /* inline */ public this()//{
    //Clear();
    //}

    public final void _default_ctor() {
    Clear();
    }

    /* inline */ public void Clear(){
    memset(&this, 0,  typeof(this).sizeof);
    }

    public void DeIndexAllBuffers();

    public void ScaleClipRects(ref const(ImVec2) fb_scale);

}
extern(C++)
@cppclasssize(136) align(8)
struct ImFontConfig
{


    @cppsize(8) public void* FontData;
    @cppsize(4) public int FontDataSize;
    @cppsize(1) public bool FontDataOwnedByAtlas;
    @cppsize(4) public int FontNo;
    @cppsize(4) public float SizePixels;
    @cppsize(4) public int OversampleH;
    @cppsize(4) public int OversampleV;
    @cppsize(1) public bool PixelSnapH;
    @cppsize(8) public ImVec2 GlyphExtraSpacing;
    @cppsize(8) public ImVec2 GlyphOffset;
    @cppsize(8) public const(ImWchar)* GlyphRanges;
    @cppsize(4) public float GlyphMinAdvanceX;
    @cppsize(4) public float GlyphMaxAdvanceX;
    @cppsize(1) public bool MergeMode;
    @cppsize(4) public uint FontBuilderFlags;
    @cppsize(4) public float RasterizerMultiply;
    @cppsize(2) public ImWchar EllipsisChar;
    @cppsize(40) public char[40] Name;
    @cppsize(8) public ImFont* DstFont;
    // public this();

    pragma (mangle, "??0ImFontConfig@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

}
extern(C++)
@cppclasssize(40) align(4)
struct ImFontGlyph
{
align(4):


    mixin(bitfields!(
        uint, "Colored", 1,
        uint, "Visible", 1,
        uint, "Codepoint", 30));
    @cppsize(4) public float AdvanceX;
    @cppsize(4) public float X0;
    @cppsize(4) public float Y0;
    @cppsize(4) public float X1;
    @cppsize(4) public float Y1;
    @cppsize(4) public float U0;
    @cppsize(4) public float V0;
    @cppsize(4) public float U1;
    @cppsize(4) public float V1;
}
extern(C++)
@cppclasssize(16) align(8)
struct ImFontGlyphRangesBuilder
{


    @cppsize(16) public ImVector!(ImU32) UsedChars;
    // /* inline */ public this()//{
    //Clear();
    //}

    public final void _default_ctor() {
    Clear();
    }

    /* inline */ public void Clear(){
    int size_in_bytes = (65535 + 1) / 8;
    UsedChars.resize(size_in_bytes / cast(int)(ImU32).sizeof);
    memset(UsedChars.Data, 0, cast(size_t)size_in_bytes);
    }

    /* inline */ public bool GetBit(size_t n) const {
    int off = cast(int)(n >> 5);
    ImU32 mask = 1U << cast(uint) ((n & 31));
    return (UsedChars[off] & mask) != 0;
    }

    /* inline */ public void SetBit(size_t n){
    int off = cast(int)(n >> 5);
    ImU32 mask = 1U << cast(uint) ((n & 31));
    UsedChars[off] |= mask;
    }

    /* inline */ public void AddChar(ImWchar c){
    SetBit(c);
    }

    public void AddText(const(char)* text, const(char)* text_end = null);

    public void AddRanges(const(ImWchar)* ranges);

    public void BuildRanges(ImVector!(ImWchar)* out_ranges);

}
extern(C++)
@cppclasssize(32) align(8)
struct ImFontAtlasCustomRect
{


    @cppsize(2) public ushort Width;
    @cppsize(2) public ushort Height;
    @cppsize(2) public ushort X;
    @cppsize(2) public ushort Y;
    @cppsize(4) public uint GlyphID;
    @cppsize(4) public float GlyphAdvanceX;
    @cppsize(8) public ImVec2 GlyphOffset;
    @cppsize(8) public ImFont* Font;
    // /* inline */ public this()//{
    //Width = Height = 0;
    //X = Y = 65535;
    //GlyphID = 0;
    //GlyphAdvanceX = 0f;
    //GlyphOffset = ImVec2(0, 0);
    //Font = null;
    //}

    public final void _default_ctor() {
    Width = Height = 0;
    X = Y = 65535;
    GlyphID = 0;
    GlyphAdvanceX = 0f;
    GlyphOffset = ImVec2(0, 0);
    Font = null;
    }

    /* inline */ public bool IsPacked() const {
    return X != 65535;
    }

}
enum ImFontAtlasFlags_
{
    ImFontAtlasFlags_None = 0, 
    ImFontAtlasFlags_NoPowerOfTwoHeight = 1, 
    ImFontAtlasFlags_NoMouseCursors = 2, 
    ImFontAtlasFlags_NoBakedLines = 4, 
}

alias ImFontAtlasFlags_None = ImFontAtlasFlags_.ImFontAtlasFlags_None;
alias ImFontAtlasFlags_NoPowerOfTwoHeight = ImFontAtlasFlags_.ImFontAtlasFlags_NoPowerOfTwoHeight;
alias ImFontAtlasFlags_NoMouseCursors = ImFontAtlasFlags_.ImFontAtlasFlags_NoMouseCursors;
alias ImFontAtlasFlags_NoBakedLines = ImFontAtlasFlags_.ImFontAtlasFlags_NoBakedLines;

extern(C++)
@cppclasssize(1168) align(8)
struct ImFontAtlas
{


    alias CustomRect = ImFontAtlasCustomRect;

    alias GlyphRangesBuilder = ImFontGlyphRangesBuilder;

    @cppsize(4) public ImFontAtlasFlags Flags;
    @cppsize(8) public void* TexID;
    @cppsize(4) public int TexDesiredWidth;
    @cppsize(4) public int TexGlyphPadding;
    @cppsize(1) public bool Locked;
    @cppsize(1) public bool TexPixelsUseColors;
    @cppsize(8) public ubyte* TexPixelsAlpha8;
    @cppsize(8) public uint* TexPixelsRGBA32;
    @cppsize(4) public int TexWidth;
    @cppsize(4) public int TexHeight;
    @cppsize(8) public ImVec2 TexUvScale;
    @cppsize(8) public ImVec2 TexUvWhitePixel;
    @cppsize(16) public ImVector!(ImFont*) Fonts;
    @cppsize(16) public ImVector!(ImFontAtlasCustomRect) CustomRects;
    @cppsize(16) public ImVector!(ImFontConfig) ConfigData;
    @cppsize(1024) public ImVec4[64] TexUvLines;
    @cppsize(8) public const(ImFontBuilderIO)* FontBuilderIO;
    @cppsize(4) public uint FontBuilderFlags;
    @cppsize(4) public int PackIdMouseCursors;
    @cppsize(4) public int PackIdLines;
    // public this();

    pragma (mangle, "??0ImFontAtlas@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

    public ~this();

    public ImFont* AddFont(const(ImFontConfig)* font_cfg);

    public ImFont* AddFontDefault(const(ImFontConfig)* font_cfg = null);

    public ImFont* AddFontFromFileTTF(const(char)* filename, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null);

    public ImFont* AddFontFromMemoryTTF(void* font_data, int font_size, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null);

    public ImFont* AddFontFromMemoryCompressedTTF(const(void)* compressed_font_data, int compressed_font_size, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null);

    public ImFont* AddFontFromMemoryCompressedBase85TTF(const(char)* compressed_font_data_base85, float size_pixels, const(ImFontConfig)* font_cfg = null, const(ImWchar)* glyph_ranges = null);

    public void ClearInputData();

    public void ClearTexData();

    public void ClearFonts();

    public void Clear();

    public bool Build();

    public void GetTexDataAsAlpha8(ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel = null);

    public void GetTexDataAsRGBA32(ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel = null);

    /* inline */ public bool IsBuilt() const {
    return Fonts.Size > 0 && (TexPixelsAlpha8 != null || TexPixelsRGBA32 != null);
    }

    /* inline */ public void SetTexID(void* id){
    TexID = id;
    }

    public const(ImWchar)* GetGlyphRangesDefault();

    public const(ImWchar)* GetGlyphRangesKorean();

    public const(ImWchar)* GetGlyphRangesJapanese();

    public const(ImWchar)* GetGlyphRangesChineseFull();

    public const(ImWchar)* GetGlyphRangesChineseSimplifiedCommon();

    public const(ImWchar)* GetGlyphRangesCyrillic();

    public const(ImWchar)* GetGlyphRangesThai();

    public const(ImWchar)* GetGlyphRangesVietnamese();

    public int AddCustomRectRegular(int width, int height);

    public int AddCustomRectFontGlyph(ImFont* font, ImWchar id, int width, int height, float advance_x, ref const(ImVec2) offset = ImVec2(0, 0).byRef );

    /* inline */ public ImFontAtlasCustomRect* GetCustomRectByIndex(int index){
    assert(!!(index >= 0), "index >= 0");
    return &CustomRects[index];
    }

    public void CalcCustomRectUV(const(ImFontAtlasCustomRect)* rect, ImVec2* out_uv_min, ImVec2* out_uv_max) const ;

    public bool GetMouseCursorTexData(ImGuiMouseCursor cursor, ImVec2* out_offset, ImVec2* out_size, ImVec2* out_uv_border, ImVec2* out_uv_fill);

}
extern(C++)
@cppclasssize(112) align(8)
struct ImFont
{


    @cppsize(16) public ImVector!(float) IndexAdvanceX;
    @cppsize(4) public float FallbackAdvanceX;
    @cppsize(4) public float FontSize;
    @cppsize(16) public ImVector!(ImWchar) IndexLookup;
    @cppsize(16) public ImVector!(ImFontGlyph) Glyphs;
    @cppsize(8) public const(ImFontGlyph)* FallbackGlyph;
    @cppsize(8) public ImFontAtlas* ContainerAtlas;
    @cppsize(8) public const(ImFontConfig)* ConfigData;
    @cppsize(2) public short ConfigDataCount;
    @cppsize(2) public ImWchar FallbackChar;
    @cppsize(2) public ImWchar EllipsisChar;
    @cppsize(1) public bool DirtyLookupTables;
    @cppsize(4) public float Scale;
    @cppsize(4) public float Ascent;
    @cppsize(4) public float Descent;
    @cppsize(4) public int MetricsTotalSurface;
    @cppsize(2) public ImU8[2] Used4kPagesMap;
    // public this();

    pragma (mangle, "??0ImFont@@QEAA@XZ")
    extern(C++) public final void _default_ctor();

    public ~this();

    public const(ImFontGlyph)* FindGlyph(ImWchar c) const ;

    public const(ImFontGlyph)* FindGlyphNoFallback(ImWchar c) const ;

    /* inline */ public float GetCharAdvance(ImWchar c) const {
    return (cast(int)c < IndexAdvanceX.Size) ? IndexAdvanceX[cast(int)c] : FallbackAdvanceX;
    }

    /* inline */ public bool IsLoaded() const {
    return ContainerAtlas != null;
    }

    /* inline */ public const(char)* GetDebugName() const {
    return ConfigData ? ConfigData.Name.ptr : "<unknown>";
    }

    public ImVec2 CalcTextSizeA(float size, float max_width, float wrap_width, const(char)* text_begin, const(char)* text_end = null, const(char)** remaining = null) const ;

    public const(char)* CalcWordWrapPositionA(float scale, const(char)* text, const(char)* text_end, float wrap_width) const ;

    public void RenderChar(ImDrawList* draw_list, float size, ImVec2 pos, ImU32 col, ImWchar c) const ;

    public void RenderText(ImDrawList* draw_list, float size, ImVec2 pos, ImU32 col, ref const(ImVec4) clip_rect, const(char)* text_begin, const(char)* text_end, float wrap_width = 0f, bool cpu_fine_clip = false) const ;

    public void BuildLookupTable();

    public void ClearOutputData();

    public void GrowIndex(int new_size);

    public void AddGlyph(const(ImFontConfig)* src_cfg, ImWchar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advance_x);

    public void AddRemapChar(ImWchar dst, ImWchar src, bool overwrite_dst = true);

    public void SetGlyphVisible(ImWchar c, bool visible);

    public void SetFallbackChar(ImWchar c);

    public bool IsGlyphRangeUnused(uint c_begin, uint c_last);

}
enum ImGuiViewportFlags_
{
    ImGuiViewportFlags_None = 0, 
    ImGuiViewportFlags_IsPlatformWindow = 1, 
    ImGuiViewportFlags_IsPlatformMonitor = 2, 
    ImGuiViewportFlags_OwnedByApp = 4, 
}

alias ImGuiViewportFlags_None = ImGuiViewportFlags_.ImGuiViewportFlags_None;
alias ImGuiViewportFlags_IsPlatformWindow = ImGuiViewportFlags_.ImGuiViewportFlags_IsPlatformWindow;
alias ImGuiViewportFlags_IsPlatformMonitor = ImGuiViewportFlags_.ImGuiViewportFlags_IsPlatformMonitor;
alias ImGuiViewportFlags_OwnedByApp = ImGuiViewportFlags_.ImGuiViewportFlags_OwnedByApp;

extern(C++)
@cppclasssize(36) align(4)
struct ImGuiViewport
{


    @cppsize(4) public ImGuiViewportFlags Flags;
    @cppsize(8) public ImVec2 Pos;
    @cppsize(8) public ImVec2 Size;
    @cppsize(8) public ImVec2 WorkPos;
    @cppsize(8) public ImVec2 WorkSize;
    // /* inline */ public this()//{
    //memset(&this, 0,  typeof(this).sizeof);
    //}

    public final void _default_ctor() {
    memset(&this, 0,  typeof(this).sizeof);
    }

    /* inline */ public ImVec2 GetCenter() const {
    return ImVec2(Pos.x + Size.x * 0.5f, Pos.y + Size.y * 0.5f);
    }

    /* inline */ public ImVec2 GetWorkCenter() const {
    return ImVec2(WorkPos.x + WorkSize.x * 0.5f, WorkPos.y + WorkSize.y * 0.5f);
    }

}
extern(C++, "ImGui")
bool ListBoxHeader(const(char)* label, int items_count, int height_in_items = -1);

extern(C++, "ImGui")
bool ListBoxHeader(const(char)* label, ref const(ImVec2) size = ImVec2(0, 0).byRef ){
return BeginListBox(label, size);
}

extern(C++, "ImGui")
void ListBoxFooter(){
EndListBox();
}

extern(C++, "ImGui")
void OpenPopupContextItem(const(char)* str_id = null, ImGuiMouseButton mb = 1){
OpenPopupOnItemClick(str_id, mb);
}

extern(C++, "ImGui")
bool DragScalar(const(char)* label, ImGuiDataType data_type, void* p_data, float v_speed, const(void)* p_min, const(void)* p_max, const(char)* format, float power);

extern(C++, "ImGui")
bool DragScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed, const(void)* p_min, const(void)* p_max, const(char)* format, float power);

extern(C++, "ImGui")
bool DragFloat(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, float power){
return DragScalar(label, ImGuiDataType_Float, v, v_speed, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool DragFloat2(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, float power){
return DragScalarN(label, ImGuiDataType_Float, v, 2, v_speed, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool DragFloat3(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, float power){
return DragScalarN(label, ImGuiDataType_Float, v, 3, v_speed, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool DragFloat4(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, float power){
return DragScalarN(label, ImGuiDataType_Float, v, 4, v_speed, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool SliderScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format, float power);

extern(C++, "ImGui")
bool SliderScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_min, const(void)* p_max, const(char)* format, float power);

extern(C++, "ImGui")
bool SliderFloat(const(char)* label, float* v, float v_min, float v_max, const(char)* format, float power){
return SliderScalar(label, ImGuiDataType_Float, v, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool SliderFloat2(const(char)* label, float* v, float v_min, float v_max, const(char)* format, float power){
return SliderScalarN(label, ImGuiDataType_Float, v, 2, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool SliderFloat3(const(char)* label, float* v, float v_min, float v_max, const(char)* format, float power){
return SliderScalarN(label, ImGuiDataType_Float, v, 3, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool SliderFloat4(const(char)* label, float* v, float v_min, float v_max, const(char)* format, float power){
return SliderScalarN(label, ImGuiDataType_Float, v, 4, &v_min, &v_max, format, power);
}

extern(C++, "ImGui")
bool BeginPopupContextWindow(const(char)* str_id, ImGuiMouseButton mb, bool over_items){
return BeginPopupContextWindow(str_id, mb | (over_items ? 0 : ImGuiPopupFlags_NoOpenOverItems));
}

extern(C++, "ImGui")
void TreeAdvanceToLabelPos(){
SetCursorPosX(GetCursorPosX() + GetTreeNodeToLabelSpacing());
}

extern(C++, "ImGui")
void SetNextTreeNodeOpen(bool open, ImGuiCond cond = 0){
SetNextItemOpen(open, cond);
}

extern(C++, "ImGui")
float GetContentRegionAvailWidth(){
return GetContentRegionAvail().x;
}

extern(C++, "ImGui")
ImDrawList* GetOverlayDrawList(){
return GetForegroundDrawList();
}

alias ImDrawCornerFlags = ImDrawFlags;

enum ImDrawCornerFlags_
{
    ImDrawCornerFlags_None = 256, 
    ImDrawCornerFlags_TopLeft = 16, 
    ImDrawCornerFlags_TopRight = 32, 
    ImDrawCornerFlags_BotLeft = 64, 
    ImDrawCornerFlags_BotRight = 128, 
    ImDrawCornerFlags_All = 240, 
    ImDrawCornerFlags_Top = 48, 
    ImDrawCornerFlags_Bot = 192, 
    ImDrawCornerFlags_Left = 80, 
    ImDrawCornerFlags_Right = 160, 
}

alias ImDrawCornerFlags_None = ImDrawCornerFlags_.ImDrawCornerFlags_None;
alias ImDrawCornerFlags_TopLeft = ImDrawCornerFlags_.ImDrawCornerFlags_TopLeft;
alias ImDrawCornerFlags_TopRight = ImDrawCornerFlags_.ImDrawCornerFlags_TopRight;
alias ImDrawCornerFlags_BotLeft = ImDrawCornerFlags_.ImDrawCornerFlags_BotLeft;
alias ImDrawCornerFlags_BotRight = ImDrawCornerFlags_.ImDrawCornerFlags_BotRight;
alias ImDrawCornerFlags_All = ImDrawCornerFlags_.ImDrawCornerFlags_All;
alias ImDrawCornerFlags_Top = ImDrawCornerFlags_.ImDrawCornerFlags_Top;
alias ImDrawCornerFlags_Bot = ImDrawCornerFlags_.ImDrawCornerFlags_Bot;
alias ImDrawCornerFlags_Left = ImDrawCornerFlags_.ImDrawCornerFlags_Left;
alias ImDrawCornerFlags_Right = ImDrawCornerFlags_.ImDrawCornerFlags_Right;

struct ImGuiContext;
struct ImDrawListSharedData;
struct ImFontBuilderIO;
