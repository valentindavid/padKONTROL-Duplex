duplex_configurations:insert {
  name = "Test",
  pinned = true,

  device = {
    class_name = "padKONTROL",          
    display_name = "padKONTROL",
    device_port_in = "padKONTROL",
    device_port_out = "padKONTROL",
    control_map = "Controllers/padKONTROL/Controlmaps/padKONTROL.xml",
    protocol = DEVICE_PROTOCOL.MIDI
  },
  
  applications = {
     A = {
        application = "Constant",
        mappings = {
           control = {
              group_name = "EnablePads",
              index = 9,
              value = "1",
           }
        },
     },
     B = {
        application = "Constant",
        mappings = {
           control = {
              group_name = "MapPads",
              index = 9,
              value = "30",
           }
        },
     },
    Transport = {
      mappings = {
        stop_playback = {
          group_name= "Pads",
          index = 1,
        },
        edit_mode = {
          group_name = "Pads",
          index = 2,
        },
        start_playback = {
          group_name = "Pads",
          index = 3,
        },
        loop_pattern = {
          group_name = "Pads",
          index = 4,
        },
        follow_player = {
          group_name = "Pads",
          index = 5,
        },
        bpm_display = {
           group_name = "Display",
           index  = 1,
        },
      },
      options = {
        pattern_play = 3,
      }
    },
    XYPad = {
      mappings = {
        xy_pad = {
          group_name = "XY",
          index = 1
        },
      },
    },
    Mixer = {
      mappings = {
        master = {
          group_name = "Knob1",
          index = 2
        },
      },
    },
   TrackSelector = {
      mappings = {
         prev_track = {
          group_name = "Setting",
          index = 1
        },
         next_track = {
          group_name = "Setting",
          index = 2
        },
      },
    },
    SwitchConfiguration = {
      mappings = {
        goto_previous = {
          group_name = "Setting",
          index = 4,
        },
        goto_next = {
          group_name = "Setting",
          index = 5,
        },
      }
    },
  }
}



