return {
  version = "1.4",
  luaversion = "5.1",
  tiledversion = "2021.01.13",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 50,
  height = 50,
  tilewidth = 32,
  tileheight = 32,
  nextlayerid = 6,
  nextobjectid = 18,
  properties = {},
  tilesets = {
    {
      name = "tileset",
      firstgid = 1,
      tilewidth = 32,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      columns = 9,
      image = "../myTiles/tileset.png",
      imagewidth = 288,
      imageheight = 608,
      objectalignment = "unspecified",
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 32,
        height = 32
      },
      properties = {},
      terrains = {},
      wangsets = {},
      tilecount = 171,
      tiles = {
        {
          id = 0,
          properties = {
            ["damage"] = 2
          },
          animation = {
            {
              tileid = 33,
              duration = 100
            },
            {
              tileid = 34,
              duration = 100
            },
            {
              tileid = 35,
              duration = 100
            }
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      id = 1,
      name = "background",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJztw8EJAAAMA6F7ZP+ZO0dBwVVTVVVVVVVVVVXV5w+SZScR"
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      id = 2,
      name = "walls",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {
        ["collidable"] = true
      },
      encoding = "base64",
      compression = "zlib",
      data = "eJztmcsOhCAQBBH//589bULMssxTm9muZI40UwYU9WytnUVqd+ghoydmj/zyiOjhaY9jUhE84VLNI3vubBd66LDmScfRQ48lkx72OVfQYw33uY63PCLpbX8Pj8NnvIQMj34rb5aEaI+I3u95EiI8oq79LFeCxyOr/zFbisUjs/8xX4PWI7N/T77GI3sNebK1Ht/GW4lcn294ZOwvhHUVAdo+t2J9fqD58Ds1FvTAoroH0r1Iwj947OSy+q+W/a5hYXbO056vEMrjgQw9sKAHFvTAoppHhboAAO4DYQ=="
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      id = 3,
      name = "lava",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJzt1TEOABAQBEDC/9+sFSFKnJlkm6t2q0sJ+EFZ5DVRdgBwr3q6AABAIHnI7LbLDaLsAIBelF9lBwAAowY0KABV"
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 4,
      name = "Spawn_points",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 4,
          name = "",
          type = "",
          shape = "rectangle",
          x = 423.012,
          y = 127.749,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 54,
          visible = false,
          properties = {}
        },
        {
          id = 5,
          name = "",
          type = "",
          shape = "rectangle",
          x = 425.673,
          y = 125.088,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 54,
          visible = false,
          properties = {}
        },
        {
          id = 6,
          name = "spawn",
          type = "",
          shape = "rectangle",
          x = 383.459,
          y = 320.906,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 54,
          visible = true,
          properties = {}
        },
        {
          id = 8,
          name = "spawn",
          type = "",
          shape = "rectangle",
          x = 1271.77,
          y = 1492.61,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 54,
          visible = true,
          properties = {}
        },
        {
          id = 9,
          name = "spawn",
          type = "",
          shape = "rectangle",
          x = 750.276,
          y = 1168,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 54,
          visible = true,
          properties = {}
        },
        {
          id = 11,
          name = "spawn",
          type = "",
          shape = "rectangle",
          x = 1428.75,
          y = 242.086,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 54,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "powerups",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 13,
          name = "health",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 96,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 16,
          visible = false,
          properties = {
            ["collidable"] = false,
            ["points"] = 10
          }
        },
        {
          id = 15,
          name = "health",
          type = "",
          shape = "rectangle",
          x = 64.6667,
          y = 288,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 16,
          visible = true,
          properties = {
            ["collidable"] = true,
            ["points"] = 10
          }
        },
        {
          id = 16,
          name = "health",
          type = "",
          shape = "rectangle",
          x = 992.667,
          y = 225.333,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 16,
          visible = true,
          properties = {
            ["collidable"] = false,
            ["points"] = 10
          }
        },
        {
          id = 17,
          name = "health",
          type = "",
          shape = "rectangle",
          x = 96,
          y = 128,
          width = 32,
          height = 32,
          rotation = 0,
          gid = 16,
          visible = true,
          properties = {
            ["collidable"] = true,
            ["points"] = 10
          }
        }
      }
    }
  }
}
