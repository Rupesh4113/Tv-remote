"""
RemoteOne — Universal TV & Set-Top Box Web Remote
Deployable on Streamlit Community Cloud (streamlit.io)
"""

import os
import json
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, List, Tuple

import streamlit as st
import pandas as pd
import plotly.graph_objects as go

# Import local IR protocol dispatcher
from protocols.ir import encode_ir_command
from tests.test_voice_parser import parse_voice_command

# ---------------------------------------------------------
# Page & Theme Configuration
# ---------------------------------------------------------
st.set_page_config(
    page_title="RemoteOne — Universal Web Remote",
    page_icon="📡",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for realistic handheld remote styling
st.markdown("""
<style>
    /* Dark cyber aesthetic */
    .stApp {
        background-color: #0A0E17;
        color: #F0F4F8;
    }
    
    /* Header branding */
    .brand-title {
        font-size: 2.2rem;
        font-weight: 800;
        background: linear-gradient(135deg, #00E5FF 0%, #00E676 100%);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 0px;
    }
    .brand-subtitle {
        font-size: 0.95rem;
        color: #8A99AD;
        margin-bottom: 20px;
    }

    /* Handheld Remote Body */
    .remote-casing {
        background: #141B29;
        border: 2px solid #233048;
        border-radius: 28px;
        padding: 24px;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.6), inset 0 1px 1px rgba(255, 255, 255, 0.1);
        max-width: 420px;
        margin: 0 auto;
    }

    /* Status LED */
    .status-led {
        display: inline-block;
        width: 12px;
        height: 12px;
        border-radius: 50%;
        background-color: #00E676;
        box-shadow: 0 0 10px #00E676;
        margin-right: 8px;
    }

    /* Badge tags */
    .tech-badge {
        display: inline-block;
        background: #1B2436;
        border: 1px solid #2A3B59;
        border-radius: 6px;
        padding: 2px 8px;
        font-size: 0.75rem;
        color: #00E5FF;
        margin-right: 4px;
    }
</style>
""", unsafe_allow_html=True)

# ---------------------------------------------------------
# Load Device Profiles Catalog
# ---------------------------------------------------------
PROFILES_DIR = Path(__file__).resolve().parent / "device-profiles"

@st.cache_data
def load_all_profiles() -> Dict[str, Dict[str, Any]]:
    profiles = {}
    if not PROFILES_DIR.exists():
        return profiles
        
    for p in PROFILES_DIR.rglob("*.json"):
        if "schema" in p.parts:
            continue
        try:
            with open(p, "r", encoding="utf-8") as f:
                data = json.load(f)
                if "id" in data and "brand" in data:
                    profiles[data["id"]] = data
        except Exception:
            pass
    return profiles

ALL_PROFILES = load_all_profiles()

# ---------------------------------------------------------
# Session State Initialization
# ---------------------------------------------------------
if "event_logs" not in st.session_state:
    st.session_state.event_logs = []

if "active_device_id" not in st.session_state:
    # Default to Tata Play or Samsung if available
    default_id = "stb-tata-play" if "stb-tata-play" in ALL_PROFILES else (list(ALL_PROFILES.keys())[0] if ALL_PROFILES else "")
    st.session_state.active_device_id = default_id

if "last_action" not in st.session_state:
    st.session_state.last_action = "Ready"

def log_event(device_name: str, transport: str, protocol: str, command: str, hex_val: str, status: str = "SUCCESS"):
    entry = {
        "Time": datetime.now().strftime("%H:%M:%S.%f")[:-3],
        "Device": device_name,
        "Transport": transport,
        "Protocol": protocol,
        "Command": command,
        "Payload": hex_val,
        "Status": status
    }
    st.session_state.event_logs.insert(0, entry)
    if len(st.session_state.event_logs) > 50:
        st.session_state.event_logs.pop()
    st.session_state.last_action = f"Transmitted '{command}' to {device_name}"

# ---------------------------------------------------------
# Sidebar: Active Device Selector & System Status
# ---------------------------------------------------------
with st.sidebar:
    st.markdown('<div class="brand-title">RemoteOne</div>', unsafe_allow_html=True)
    st.markdown('<div class="brand-subtitle">Universal TV & Set-Top Box Remote</div>', unsafe_allow_html=True)
    
    st.markdown("---")
    st.subheader("Active Controlled Device")
    
    profile_options = {pid: f"{p.get('brand')} — {p.get('model', p.get('name', pid))} ({p.get('category', '').upper()})" for pid, p in ALL_PROFILES.items()}
    
    selected_pid = st.selectbox(
        "Select Device",
        options=list(profile_options.keys()),
        format_func=lambda x: profile_options.get(x, x),
        index=list(profile_options.keys()).index(st.session_state.active_device_id) if st.session_state.active_device_id in profile_options else 0
    )
    st.session_state.active_device_id = selected_pid
    
    active_profile = ALL_PROFILES.get(selected_pid, {})
    
    if active_profile:
        st.markdown(f"**Brand:** {active_profile.get('brand')}")
        st.markdown(f"**Category:** {active_profile.get('category', '').upper()}")
        transports = active_profile.get("supported_transports", ["ir"])
        st.markdown("**Transports:** " + " ".join([f"<span class='tech-badge'>{t.upper()}</span>" for t in transports]), unsafe_allow_html=True)
        if "ir" in [t.lower() for t in transports]:
            ir_info = active_profile.get("ir", {})
            st.markdown(f"**IR Protocol:** `{ir_info.get('default_protocol', 'NEC')}`")
            st.markdown(f"**Carrier:** `{ir_info.get('carrier_frequency_hz', 38000)} Hz`")
    
    st.markdown("---")
    st.subheader("Hardware Status")
    st.markdown("🟢 **Web Remote Simulator:** Active")
    st.markdown("📡 **Local Discovery Engine:** Ready")
    st.markdown("📱 **Android Native App:** [Download APK](#download-android-apk)")
    
    st.markdown("---")
    st.caption("RemoteOne Open-Source Project • v1.0.0")

# ---------------------------------------------------------
# Main Tabs
# ---------------------------------------------------------
tab_remote, tab_profiles, tab_waveform, tab_voice, tab_download = st.tabs([
    "📱 Mobile Web Remote",
    "📡 Device Profiles Library",
    "🔬 IR Waveform Analyzer",
    "🎙️ Voice & Macro Studio",
    "📥 Download Android APK"
])

# ---------------------------------------------------------
# TAB 1: Mobile Web Remote
# ---------------------------------------------------------
with tab_remote:
    st.markdown(f"### Controlling: **{active_profile.get('brand', 'Device')} {active_profile.get('model', '')}**")
    
    col_remote, col_console = st.columns([1, 1])
    
    with col_remote:
        st.markdown('<div class="remote-casing">', unsafe_allow_html=True)
        
        # Row 1: Top Bar (Power, Source, Mute, Settings)
        r1_c1, r1_c2, r1_c3, r1_c4 = st.columns(4)
        with r1_c1:
            if st.button("🔴 POWER", key="btn_power", use_container_width=True, help="Power Toggle"):
                cmd = active_profile.get("commands", {}).get("POWER", {})
                hex_c = cmd.get("hex", "0xE0E040BF")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "POWER", hex_c)
        with r1_c2:
            if st.button("INPUT", key="btn_input", use_container_width=True, help="Input / Source"):
                cmd = active_profile.get("commands", {}).get("INPUT", {})
                hex_c = cmd.get("hex", "0xE0E0807F")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "INPUT", hex_c)
        with r1_c3:
            if st.button("🔇 MUTE", key="btn_mute", use_container_width=True, help="Mute Audio"):
                cmd = active_profile.get("commands", {}).get("MUTE", {})
                hex_c = cmd.get("hex", "0xE0E0F00F")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "MUTE", hex_c)
        with r1_c4:
            if st.button("⚙️ MENU", key="btn_menu", use_container_width=True, help="Settings / Menu"):
                cmd = active_profile.get("commands", {}).get("MENU", {})
                hex_c = cmd.get("hex", "0xE0E058A7")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "MENU", hex_c)

        st.markdown("<div style='height: 12px;'></div>", unsafe_allow_html=True)

        # Row 2: Volume & Channel Rockers
        rk_c1, rk_c2 = st.columns(2)
        with rk_c1:
            st.markdown("<div style='text-align:center; font-weight:bold; font-size:12px; color:#8A99AD;'>VOLUME</div>", unsafe_allow_html=True)
            if st.button("🔊 VOL +", key="btn_vol_up", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("VOLUME_UP", {})
                hex_c = cmd.get("hex", "0xE0E0E01F")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "VOLUME_UP", hex_c)
            if st.button("🔉 VOL -", key="btn_vol_down", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("VOLUME_DOWN", {})
                hex_c = cmd.get("hex", "0xE0E0D02F")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "VOLUME_DOWN", hex_c)
        with rk_c2:
            st.markdown("<div style='text-align:center; font-weight:bold; font-size:12px; color:#8A99AD;'>CHANNEL</div>", unsafe_allow_html=True)
            if st.button("🔼 CH +", key="btn_ch_up", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("CHANNEL_UP", {})
                hex_c = cmd.get("hex", "0xE0E048B7")
                log_event(active_profile.get("brand", "STB"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "CHANNEL_UP", hex_c)
            if st.button("🔽 CH -", key="btn_ch_down", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("CHANNEL_DOWN", {})
                hex_c = cmd.get("hex", "0xE0E008F7")
                log_event(active_profile.get("brand", "STB"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "CHANNEL_DOWN", hex_c)

        st.markdown("<div style='height: 12px;'></div>", unsafe_allow_html=True)

        # Row 3: 5-Way Directional Navigation Pad
        st.markdown("<div style='text-align:center; font-weight:bold; font-size:12px; color:#8A99AD;'>NAVIGATION</div>", unsafe_allow_html=True)
        dp_u1, dp_u2, dp_u3 = st.columns([1, 2, 1])
        with dp_u2:
            if st.button("⬆️ UP", key="btn_up", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("UP", {})
                hex_c = cmd.get("hex", "0xE0E006F9")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "UP", hex_c)

        dp_m1, dp_m2, dp_m3 = st.columns([1, 2, 1])
        with dp_m1:
            if st.button("⬅️", key="btn_left", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("LEFT", {})
                hex_c = cmd.get("hex", "0xE0E0A659")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "LEFT", hex_c)
        with dp_m2:
            if st.button("🔘 OK", key="btn_ok", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("ENTER", active_profile.get("commands", {}).get("OK", {}))
                hex_c = cmd.get("hex", "0xE0E016E9")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "OK", hex_c)
        with dp_m3:
            if st.button("➡️", key="btn_right", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("RIGHT", {})
                hex_c = cmd.get("hex", "0xE0E046B9")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "RIGHT", hex_c)

        dp_d1, dp_d2, dp_d3 = st.columns([1, 2, 1])
        with dp_d2:
            if st.button("⬇️ DOWN", key="btn_down", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("DOWN", {})
                hex_c = cmd.get("hex", "0xE0E08679")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "DOWN", hex_c)

        # Back & Home
        bh_c1, bh_c2 = st.columns(2)
        with bh_c1:
            if st.button("↩️ BACK", key="btn_back", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("BACK", {})
                hex_c = cmd.get("hex", "0xE0E01AE5")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "BACK", hex_c)
        with bh_c2:
            if st.button("🏠 HOME", key="btn_home", use_container_width=True):
                cmd = active_profile.get("commands", {}).get("HOME", {})
                hex_c = cmd.get("hex", "0xE0E09E61")
                log_event(active_profile.get("brand", "TV"), "IR", active_profile.get("ir", {}).get("default_protocol", "NEC"), "HOME", hex_c)

        st.markdown("<div style='height: 12px;'></div>", unsafe_allow_html=True)

        # Row 4: Numeric Keypad (Collapsible)
        with st.expander("🔢 Number Keypad (0-9)"):
            n1, n2, n3 = st.columns(3)
            with n1:
                if st.button("1", key="num_1", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_1", "0xE0E020DF")
            with n2:
                if st.button("2", key="num_2", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_2", "0xE0E0A05F")
            with n3:
                if st.button("3", key="num_3", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_3", "0xE0E0609F")
            
            n4, n5, n6 = st.columns(3)
            with n4:
                if st.button("4", key="num_4", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_4", "0xE0E010EF")
            with n5:
                if st.button("5", key="num_5", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_5", "0xE0E0906F")
            with n6:
                if st.button("6", key="num_6", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_6", "0xE0E050AF")

            n7, n8, n9 = st.columns(3)
            with n7:
                if st.button("7", key="num_7", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_7", "0xE0E030CF")
            with n8:
                if st.button("8", key="num_8", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_8", "0xE0E0B04F")
            with n9:
                if st.button("9", key="num_9", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_9", "0xE0E0708F")

            n_dot, n0, n_ent = st.columns(3)
            with n_dot:
                if st.button("FAV", key="num_fav", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "FAV", "0xE0E0F807")
            with n0:
                if st.button("0", key="num_0", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "NUM_0", "0xE0E08877")
            with n_ent:
                if st.button("INFO", key="num_info", use_container_width=True):
                    log_event(active_profile.get("brand", "STB"), "IR", "NEC", "INFO", "0xE0E0F807")

        # Row 5: Streaming Apps
        with st.expander("📺 Smart TV App Shortcuts"):
            app1, app2 = st.columns(2)
            with app1:
                if st.button("🔴 YouTube", key="btn_yt", use_container_width=True):
                    log_event(active_profile.get("brand", "TV"), "Wi-Fi / REST", "JSON-RPC", "LAUNCH_YOUTUBE", "org.youtube.tv")
                if st.button("📦 Prime Video", key="btn_pv", use_container_width=True):
                    log_event(active_profile.get("brand", "TV"), "Wi-Fi / REST", "JSON-RPC", "LAUNCH_PRIME", "amazon.primevideo")
            with app2:
                if st.button("🍿 Netflix", key="btn_nf", use_container_width=True):
                    log_event(active_profile.get("brand", "TV"), "Wi-Fi / REST", "JSON-RPC", "LAUNCH_NETFLIX", "com.netflix.ninja")
                if st.button("✨ Disney+ Hotstar", key="btn_ds", use_container_width=True):
                    log_event(active_profile.get("brand", "TV"), "Wi-Fi / REST", "JSON-RPC", "LAUNCH_HOTSTAR", "in.startv.hotstar")

        st.markdown('</div>', unsafe_allow_html=True)

    with col_console:
        st.subheader("Transmission Event Stream")
        st.info(f"Last Status: **{st.session_state.last_action}**")
        
        if st.session_state.event_logs:
            df_logs = pd.DataFrame(st.session_state.event_logs)
            st.dataframe(df_logs, use_container_width=True, hide_index=True)
            if st.button("Clear Log Stream"):
                st.session_state.event_logs = []
                st.rerun()
        else:
            st.caption("No commands sent yet. Press any remote button on the left to simulate transmission.")

        st.markdown("---")
        st.subheader("Live Protocol Encoder Breakdown")
        test_hex = active_profile.get("commands", {}).get("POWER", {}).get("hex", "0xE0E040BF")
        proto = active_profile.get("ir", {}).get("default_protocol", "NEC")
        carrier, pulses = encode_ir_command(proto, test_hex)
        
        st.markdown(f"**Sample Button:** `POWER` (`{test_hex}`)")
        st.markdown(f"**Carrier Frequency:** `{carrier} Hz`")
        st.markdown(f"**Waveform Pulse Count:** `{len(pulses)} alternating mark/space intervals`")
        st.markdown(f"**Lead-in Pulse:** `{pulses[0]} μs mark, {pulses[1]} μs space`")
        st.caption("The full pulse train is passed natively into Android's ConsumerIrManager or emitted via network socket.")

# ---------------------------------------------------------
# TAB 2: Device Profiles Library
# ---------------------------------------------------------
with tab_profiles:
    st.subheader("Open-Source Device Profile Catalog")
    st.markdown("Explore pre-configured timing specifications and command dictionaries for Indian DTH Set-Top Boxes and Smart TVs.")
    
    col_f1, col_f2 = st.columns([1, 2])
    with col_f1:
        cat_filter = st.selectbox("Filter by Category", ["All", "TV", "Set-Top Box"])
    with col_f2:
        search_filter = st.text_input("Search Brand or Model", placeholder="e.g. Tata Play, Sony, LG, Airtel...")

    filtered_profiles = []
    for pid, p in ALL_PROFILES.items():
        if cat_filter != "All" and p.get("category", "").lower() != cat_filter.lower().replace(" ", "").replace("-", ""):
            continue
        if search_filter:
            kw = search_filter.lower()
            if kw not in p.get("brand", "").lower() and kw not in p.get("model", "").lower() and kw not in pid.lower():
                continue
        filtered_profiles.append((pid, p))

    st.write(f"Showing **{len(filtered_profiles)}** device profiles:")

    for pid, p in filtered_profiles:
        with st.expander(f"📦 {p.get('brand')} — {p.get('model', p.get('name', pid))} ({p.get('category', '').upper()})"):
            c_meta, c_actions = st.columns([3, 1])
            with c_meta:
                st.markdown(f"**Profile ID:** `{pid}` | **Region:** `{p.get('region', 'India / Global')}`")
                st.markdown(f"**Supported Transports:** {', '.join(p.get('supported_transports', []))}")
                ir_spec = p.get("ir", {})
                if ir_spec:
                    st.markdown(f"**IR Protocol:** `{ir_spec.get('default_protocol', 'NEC')}` @ `{ir_spec.get('carrier_frequency_hz', 38000)} Hz`")
            with c_actions:
                if st.button("Set as Active Remote", key=f"sel_{pid}"):
                    st.session_state.active_device_id = pid
                    st.success(f"Activated {p.get('brand')}!")
                    st.rerun()

            # Commands table
            cmds = p.get("commands", {})
            if cmds:
                cmd_data = []
                for k, v in cmds.items():
                    cmd_data.append({
                        "Key": k,
                        "Label": v.get("label", k),
                        "Hex": v.get("hex", "N/A"),
                        "Protocol": v.get("protocol", p.get("ir", {}).get("default_protocol", "NEC")),
                        "Category": v.get("category", "General")
                    })
                st.dataframe(pd.DataFrame(cmd_data), use_container_width=True, hide_index=True)

            # JSON download
            st.download_button(
                label=f"⬇️ Download {pid}.json",
                data=json.dumps(p, indent=2),
                file_name=f"{pid}.json",
                mime="application/json",
                key=f"dl_{pid}"
            )

# ---------------------------------------------------------
# TAB 3: IR Waveform Analyzer
# ---------------------------------------------------------
with tab_waveform:
    st.subheader("Microsecond Infrared Pulse Waveform Visualizer")
    st.markdown("Inspect the physical mark/space carrier pulse train generated by RemoteOne's protocol timing encoders.")

    w_col1, w_col2 = st.columns([1, 2])
    with w_col1:
        sel_proto = st.selectbox("Protocol Encoding", ["NEC", "SAMSUNG", "SONY_SIRC", "RC5", "RC6"])
        
        default_hex_presets = {
            "NEC": "0x00FF00FF",
            "SAMSUNG": "0xE0E040BF",
            "SONY_SIRC": "0xA90",
            "RC5": "0x000C",
            "RC6": "0x000C"
        }
        hex_input = st.text_input("Hex Command Code", value=default_hex_presets.get(sel_proto, "0xE0E040BF"))
        
        try:
            carrier_hz, pulse_train = encode_ir_command(sel_proto, hex_input)
            total_duration_us = sum(pulse_train)
            st.success(f"Encoding: **{len(pulse_train)}** pulses generated")
            st.markdown(f"- **Carrier Frequency:** `{carrier_hz} Hz` ({carrier_hz/1000:.1f} kHz)")
            st.markdown(f"- **Total Frame Duration:** `{total_duration_us / 1000.0:.2f} ms`")
            st.markdown(f"- **Header Mark:** `{pulse_train[0]} μs`")
            st.markdown(f"- **Header Space:** `{pulse_train[1]} μs`")
        except Exception as e:
            st.error(f"Encoding Error: {e}")
            pulse_train = []

    with w_col2:
        if pulse_train:
            # Generate step graph
            time_points = [0]
            voltage_levels = [1]
            current_time = 0
            
            for idx, duration in enumerate(pulse_train):
                # Even indices: Mark (High = 1), Odd indices: Space (Low = 0)
                level = 1 if idx % 2 == 0 else 0
                current_time += duration
                time_points.extend([current_time, current_time])
                next_level = 0 if level == 1 else 1
                voltage_levels.extend([level, next_level])
                
            fig = go.Figure()
            fig.add_trace(go.Scatter(
                x=time_points,
                y=voltage_levels,
                mode='lines',
                line=dict(color='#00E5FF', width=2),
                fill='tozeroy',
                fillcolor='rgba(0, 229, 255, 0.15)',
                name="IR Pulse Waveform"
            ))
            fig.update_layout(
                title=f"{sel_proto} Timing Waveform for {hex_input} ({carrier_hz} Hz)",
                xaxis_title="Time (microseconds - μs)",
                yaxis=dict(
                    title="Modulation Level",
                    tickvals=[0, 1],
                    ticktext=["SPACE (Carrier Off)", "MARK (Carrier On)"],
                    range=[-0.2, 1.2]
                ),
                paper_bgcolor="#141B29",
                plot_bgcolor="#0A0E17",
                font=dict(color="#F0F4F8"),
                height=380,
                margin=dict(l=40, r=20, t=50, b=40)
            )
            st.plotly_chart(fig, use_container_width=True)

# ---------------------------------------------------------
# TAB 4: Voice & Macro Studio
# ---------------------------------------------------------
with tab_voice:
    st.subheader("Natural Language Voice Commands & Macro Automation")
    st.markdown("Simulate voice recognition and execute multi-step macros across your TV and Set-Top Box.")

    v_c1, v_c2 = st.columns([1, 1])
    
    with v_c1:
        st.markdown("#### 🎙️ Voice Intent Parser")
        sample_voice = st.selectbox(
            "Try a Sample Voice Query:",
            [
                "Turn on the TV",
                "Switch on Tata Play set top box",
                "Increase volume by 5",
                "Change to channel 205",
                "Open Netflix",
                "Mute the TV",
                "Turn off everything"
            ]
        )
        custom_voice = st.text_input("Or speak / type custom command:", value=sample_voice)
        
        if st.button("Execute Voice Command", use_container_width=True):
            intent_result = parse_voice_command(custom_voice)
            st.json(intent_result)
            
            target_device = intent_result.get("target", "TV")
            action = intent_result.get("command", "POWER")
            log_event(target_device, "Voice / Engine", "INTENT_DISPATCH", action, str(intent_result))
            st.success(f"Executed: {intent_result.get('intent')} on {target_device}")

    with v_c2:
        st.markdown("#### 🪄 Multi-Device Macros")
        st.caption("One-touch automation sequences that control both TV and Set-Top Box together.")

        m1, m2, m3 = st.columns(3)
        with m1:
            if st.button("🎬 Movie Night", use_container_width=True):
                with st.spinner("Running Movie Night macro..."):
                    log_event("TV", "Wi-Fi", "REST", "POWER_ON", "0xE0E040BF")
                    time.sleep(0.3)
                    log_event("TV", "Wi-Fi", "REST", "SET_INPUT_HDMI1", "SOURCE_HDMI1")
                    time.sleep(0.3)
                    log_event("STB", "IR", "NEC", "POWER_ON", "0x20DF10EF")
                    time.sleep(0.3)
                    log_event("TV", "Wi-Fi", "REST", "SET_VOLUME_18", "VOL_SET_18")
                st.success("Movie Night Macro Completed!")

        with m2:
            if st.button("⚽ Match Time", use_container_width=True):
                with st.spinner("Switching to Sports HD..."):
                    log_event("TV", "Wi-Fi", "REST", "POWER_ON", "0xE0E040BF")
                    time.sleep(0.3)
                    log_event("STB", "IR", "NEC", "CHANNEL_401", "NUM_4 -> NUM_0 -> NUM_1")
                    time.sleep(0.3)
                    log_event("TV", "Wi-Fi", "REST", "VOLUME_UP_5", "VOL_PLUS_5")
                st.success("Switched to Star Sports HD (Channel 401)!")

        with m3:
            if st.button("💤 Bedtime Off", use_container_width=True):
                with st.spinner("Powering down..."):
                    log_event("STB", "IR", "NEC", "POWER_OFF", "0x20DF10EF")
                    time.sleep(0.3)
                    log_event("TV", "Wi-Fi", "REST", "POWER_OFF", "0xE0E040BF")
                st.success("All Devices Powered Off!")

# ---------------------------------------------------------
# TAB 5: Download Android APK
# ---------------------------------------------------------
with tab_download:
    st.subheader("Download RemoteOne for Android Mobile")
    st.markdown("Install the native Android APK to use your phone's built-in **Infrared (IR) Blaster**, local **Wi-Fi discovery**, and **Bluetooth Low Energy (BLE)**.")

    d_col1, d_col2 = st.columns([1, 1])

    with d_col1:
        st.markdown("""
        <div style="background:#141B29; border:1px solid #233048; border-radius:18px; padding:24px;">
            <h3 style="color:#00E5FF; margin-top:0;">📱 RemoteOne v1.0.0 APK</h3>
            <p><strong>Package:</strong> <code>org.remoteone.app</code></p>
            <p><strong>Minimum Android Version:</strong> Android 5.0 (Lollipop, API 21+)</p>
            <p><strong>Target Architecture:</strong> ARM64, ARMv7, x86_64</p>
            <p><strong>Hardware Features:</strong></p>
            <ul>
                <li>ConsumerIrManager hardware access (No cloud required)</li>
                <li>Local Wi-Fi Subnet Scanner for Smart TVs</li>
                <li>Zero Telemetry & Local Encrypted Storage</li>
            </ul>
        </div>
        """, unsafe_allow_html=True)
        
        st.markdown("<div style='height:16px;'></div>", unsafe_allow_html=True)
        
        apk_url = "https://github.com/Rupesh4113/Tv-remote/releases/latest/download/app-release.apk"
        st.link_button("⬇️ Download app-release.apk from GitHub", apk_url, use_container_width=True)
        st.link_button("⭐ View Source Code on GitHub", "https://github.com/Rupesh4113/Tv-remote", use_container_width=True)

    with d_col2:
        st.markdown("#### 📷 Scan to Download on Phone")
        qr_api_url = f"https://api.qrserver.com/v1/create-qr-code/?size=240x240&bgcolor=0A-0E-17&color=00-E5-FF&data={apk_url}"
        st.image(qr_api_url, caption="Point your smartphone camera to download RemoteOne APK", width=240)
        
        st.markdown("""
        **Installation Steps:**
        1. Scan the QR code or tap the download button on your phone.
        2. Tap the downloaded `app-release.apk` to install.
        3. If prompted, allow *"Install unknown apps"* in Android settings.
        4. Open RemoteOne and run the **First-Run Hardware Check**!
        """)
