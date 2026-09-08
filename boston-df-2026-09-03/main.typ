#import "@preview/typslides:1.3.4": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  font: "Berkeley Mono",
  font-size: 20pt,
  link-style: "color",
  show-progress: true,
  progress-height: 5pt,
)

// Diagram styling
#let deck-blue = rgb("#3059AB")
#let deck-blue-light = rgb("#EDF3FC")
#let deck-ink = rgb("#1F2937")
#let deck-gray = rgb("#7A8492")
#let deck-gray-light = rgb("#F3F4F6")

#let diagram-node(
  pos,
  body,
  width: 50mm,
  height: 18mm,
  accent: false,
  muted: false,
) = {
  let outline = if muted { deck-gray } else { deck-blue }
  let fill = if accent {
    deck-blue
  } else if muted {
    deck-gray-light
  } else {
    deck-blue-light
  }
  let foreground = if accent { white } else if muted { deck-gray } else { deck-ink }

  node(
    pos,
    align(center + horizon, text(
      size: 12pt,
      weight: if accent { "semibold" } else { "regular" },
      fill: foreground,
    )[#body]),
    width: width,
    height: height,
    inset: 3pt,
    fill: fill,
    stroke: (paint: outline, thickness: if accent { 1.4pt } else { 1pt }),
    corner-radius: 4pt,
  )
}

#let diagram-edge(
  ..coords,
  label: none,
  label-pos: 50%,
  label-side: auto,
  muted: false,
) = {
  let color = if muted { deck-gray } else { deck-blue }

  edge(
    ..coords.pos(),
    marks: "-|>",
    stroke: (paint: color, thickness: if muted { .9pt } else { 1.25pt }),
    dash: if muted { "dashed" } else { none },
    mark-scale: 75%,
    label: if label == none { none } else {
      text(size: 9.5pt, fill: color)[#label]
    },
    label-pos: label-pos,
    label-side: label-side,
    label-fill: white,
    label-sep: 3pt,
    layer: -1,
  )
}

// Type-kind tags for the Arrow vs. Vortex type table
#let deck-green = rgb("#2E7D4F")
#let deck-green-light = rgb("#E6F4EA")

#let tag(kind) = {
  let (fill, outline, ink, label) = if kind == "core" {
    (deck-blue, deck-blue, white, "core type")
  } else if kind == "ext" {
    (deck-gray-light, deck-gray, deck-gray, "extension")
  } else if kind == "enc" {
    (deck-green-light, deck-green, deck-green, "encoding")
  } else {
    (white, deck-gray, deck-gray, kind)
  }
  h(3pt)
  box(
    baseline: 22%,
    inset: (x: 4pt, y: 2pt),
    radius: 3pt,
    fill: fill,
    stroke: 0.6pt + outline,
    text(size: 8pt, fill: ink, weight: "semibold", label),
  )
}

#let note(body) = {
  linebreak()
  text(size: 9.5pt, fill: deck-gray, body)
}

// The front slide is the first slide of your presentation
#front-slide(
  title: [I'm as Mad as Hell, and I'm Not Going to Take Physical Types Anymore!],
  authors: [Adam Gutglick - Technical Member of Staff @ Spiral
    Vortex TSC, Apache DataFusion committer],

  info: [#link("https://github.com/adamgs")],
)

#title-slide[
  What is Vortex?
]

#slide(title: "What is Vortex?")[
  - "An extensible, state-of-the-art framework for columnar compression"
  - Linux Foundation project
  - Started \@ SpiralDB, now adopted by many others.
]

#slide(title: "The Vortex Columnar File Format")[
  - Columnar file format (a la Parquet)
  - Compute on compressed data
  - Highly extensible and flexible
  - Integrates cutting edge research - FSST, OnPair, ALP, FastLanes
  - Has a Python (including Arrow Datasets), DuckDB extension, Iceberg (pending), and of course - DataFusion.
]

// #slide(title: "VortexSource")[
//   #cols()[
//     - Predicate Pushdown (mostly)
//     - Projection Pushdown
//     - Statistics
//   ][
//     #grayed[
//       ```sql
//       CREATE EXTERNAL TABLE tbl
//       STORED AS VORTEX
//       LOCATION '~/data'
//       ```
//     ]
//   ]

//   Special thanks to everyone from the DF community that helped - Andrew Lamb, Adrian Garcia Badaracco, Daniel Haas and everyone that worked on `ParquetSource`!
// ]

// Focus slide
#focus-slide(text-size: 30pt)[
  #set par(leading: 0.7em)
  #text(fill: white.transparentize(35%))[
    There is no Utf8. \
    There is no LargeUtf8. \
    There is no Utf8View.
  ]

  #v(0.5em)
  #text(size: 52pt)[There is only String.]

  // #v(1.4em)
  // #text(size: 13pt, weight: "regular", fill: white.transparentize(45%))[
  //   with apologies to Arthur Jensen, _Network_ (1976)
  // ]
]

#slide(title: "Vortex is logically typed")[
  - An array's type doesn't (fully) determine how its physically stored.
  - Primitive, Binary, String, List, etc.
  - Arrays \~ Lazy compute graph
]


#slide(title: "Arrow vs. Vortex types - not a 1:1 mapping")[
  #set text(size: 12pt)

  #table(
    columns: (auto, 1fr, 1fr),
    align: (left + horizon, left + horizon, left + horizon),
    inset: (x: 7pt, y: 4.5pt),
    stroke: (x, y) => if y == 0 { (bottom: 1pt + deck-blue) } else { (bottom: .5pt + deck-gray-light) },
    fill: (x, y) => if y == 0 { deck-blue-light } else { none },
    table.header([], [*Arrow*], [*Vortex*]),
    [Strings], [Utf8 / LargeUtf8 / Utf8View #tag("core")], [Utf8 #tag("core")],
    [Lists], [List / LargeList / ListView / LargeListView #tag("core")], [List #tag("core")],
    [Decimals],
    [Decimal32 / 64 / 128 / 256 #tag("core") #note[width is part of the type]],
    [Decimal(precision, scale) #tag("core") #note[width is a storage detail]],

    [Dictionary / RLE],
    [Dictionary\<K, V\> / RunEndEncoded #tag("core")],
    [dict / runend #tag("enc") #note[stripped on import, picked on export]],

    [Date & time],
    [Date32 / Date64 / Time32 / Time64 / Timestamp #tag("core")],
    [vortex.date / vortex.time / vortex.timestamp #tag("ext") #note[over Primitive storage]],

    [Variant],
    [arrow.parquet.variant #tag("ext") #note[over Struct\<metadata, value?, typed_value?\>]],
    [Variant #tag("core") #note[parquet.variant is one of its #tag("enc")]],
  )
]

#slide(title: "Example #1 - Export a primitive array to Arrow")[
  #align(center)[
    #text(size: 17pt, weight: "semibold", fill: deck-blue)[
      Decompress to the canonical layout, then hand Arrow the same buffer.
    ]
  ]
  #v(8mm)
  #align(center)[
    #diagram(
      spacing: (16mm, 0mm),
      cell-size: (0pt, 26mm),
      edge-corner-radius: 4pt,
      crossing-fill: white,

      diagram-edge((0, 0), (1, 0)),
      diagram-edge((1, 0), (2, 0)),

      diagram-node(
        (0, 0),
        [Encoded Vortex array #linebreak() FoR(BitPacked(i64)) #linebreak() dtype: i64],
        width: 68mm,
        height: 26mm,
      ),
      diagram-node(
        (1, 0),
        [#text(size: 15pt, weight: "semibold")[`array.to_arrow()`]],
        width: 64mm,
        height: 22mm,
      ),
      diagram-node(
        (2, 0),
        [Arrow array #linebreak() PrimitiveArray\<Int64Type\> #linebreak() #text(size: 9.5pt)[values + nulls]],
        width: 76mm,
        height: 26mm,
        accent: true,
      ),
    )
  ]

  #v(8mm)
  #align(right)[
    #text(size: 7.8pt, fill: deck-gray)[
      Docs: #link("https://docs.vortex.dev/developer-guide/internals/execution")[https://docs.vortex.dev/developer-guide/internals/execution]
      #linebreak()
      Code: #link("https://github.com/vortex-data/vortex/blob/996bb2c079330369fa8a0e5ec234212064902eef/vortex-arrow/src/executor/primitive.rs")[vortex-arrow/executor/primitive.rs]
      · #link("https://github.com/vortex-data/vortex/blob/996bb2c079330369fa8a0e5ec234212064902eef/vortex-buffer/src/arrow.rs")[vortex-buffer/arrow.rs]
    ]
  ]
]

#slide(title: "Example #2 - Stop at the requested layout")[
  #align(center)[
    #diagram(
      spacing: (8mm, 7mm),
      cell-size: (0pt, 18mm),
      edge-corner-radius: 4pt,
      crossing-fill: white,

      diagram-edge((0, 0), (1, 0)),
      diagram-edge((1, 0), (2, 0)),
      diagram-edge((2, 0), (3, 0)),
      diagram-edge((2, 1), (3, 0), muted: true),
      diagram-edge((3, 0), (3, 2), muted: true),

      diagram-node(
        (0, 0),
        [Encoded Vortex array #linebreak() Dictionary(FSST values) #linebreak() dtype: Utf8],
        width: 65mm,
        height: 26mm,
      ),
      diagram-node(
        (1, 0),
        [
          1  Metadata rewrite
          #linebreak()
          #text(size: 9.5pt)[filter(filter(x, m₁), m₂) #linebreak() → filter(x, combined mask)]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[no buffers read]
        ],
        width: 58mm,
        height: 26mm,
      ),
      diagram-node(
        (2, 0),
        [
          2  execute_parent kernel
          #linebreak()
          #text(size: 9.5pt)[LIKE(FSST(x), "http%") #linebreak() → scan compressed codes]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[operator × encoding]
        ],
        width: 58mm,
        height: 26mm,
      ),
      diagram-node(
        (3, 0),
        [Requested Arrow layout #linebreak() Dictionary\<UInt16, Utf8\> #linebreak() #text(size: 9.5pt)[MATCH → STOP]],
        width: 68mm,
        height: 26mm,
        accent: true,
      ),
      diagram-node(
        (2, 1),
        [Target matcher M #linebreak() Dictionary\<UInt16, Utf8\>],
        width: 68mm,
        height: 18mm,
        muted: true,
      ),
      diagram-node(
        (3, 2),
        [Canonical Arrow #linebreak() Utf8 #linebreak() #text(size: 9.5pt)[only when requested]],
        width: 68mm,
        height: 22mm,
        muted: true,
      ),
    )
  ]

  #v(4mm)
  #align(center)[
    #text(size: 17pt, weight: "semibold", fill: deck-blue)[
      Execute only until the requested physical layout matches.
    ]
  ]
  #v(2mm)
  #align(right)[
    #text(size: 7.8pt, fill: deck-gray)[
      Docs: #link("https://docs.vortex.dev/developer-guide/internals/execution")[https://docs.vortex.dev/developer-guide/internals/execution]
      #linebreak()
      Code: #link("https://github.com/vortex-data/vortex/blob/e7512cfb905c773597243c1205e0d9a4ea549300/vortex-array/src/arrays/filter/rules.rs")[filter/rules.rs]
      · #link("https://github.com/vortex-data/vortex/blob/e7512cfb905c773597243c1205e0d9a4ea549300/encodings/fsst/src/compute/like.rs")[fsst/compute/like.rs]
    ]
  ]
]

#title-slide[
  Variant
]

#slide(title: "What is Variant?")[
  #v(1fr)
  #align(center)[
    #text(size: 18pt, weight: "semibold", fill: deck-blue)[
      One logical type for semi-structured values.
    ]
  ]
  #v(6mm)
  #align(center)[
    #diagram(
      spacing: (14mm, 8mm),
      cell-size: (76mm, 20mm),
      edge-corner-radius: 4pt,
      crossing-fill: white,

      diagram-edge((1, 0), (0, 1)),
      diagram-edge((1, 0), (1, 1)),
      diagram-edge((1, 0), (2, 1)),

      diagram-node(
        (1, 0),
        [#text(size: 15pt, weight: "semibold")[Variant]],
        width: 66mm,
        height: 18mm,
        accent: true,
      ),
      diagram-node(
        (0, 1),
        [
          #text(size: 13pt, weight: "semibold")[PRIMITIVE]
          #linebreak()
          #text(size: 9.5pt)[#raw("\"signup\"  ·  42  ·  true")]
        ],
        width: 76mm,
        height: 24mm,
      ),
      diagram-node(
        (1, 1),
        [
          #text(size: 13pt, weight: "semibold")[ARRAY]
          #linebreak()
          #text(size: 9.5pt)[#raw("[\"rust\", 7, null]")]
        ],
        width: 76mm,
        height: 24mm,
      ),
      diagram-node(
        (2, 1),
        [
          #text(size: 13pt, weight: "semibold")[OBJECT]
          #linebreak()
          #text(size: 9.5pt)[#raw("{\"event\":\"signup\",")]
          #linebreak()
          #text(size: 9.5pt)[#raw(" \"user_id\":101}")]
        ],
        width: 76mm,
        height: 28mm,
      ),
    )
  ]
  #v(5mm)
  #align(center)[
    #text(size: 16.5pt, weight: "semibold", fill: deck-blue)[
      The table schema stays Variant even when fields and shapes change.
    ]
  ]
  #v(1fr)
  #align(right)[
    #text(size: 7.8pt, fill: deck-gray)[
      Sources:
      #link("https://github.com/apache/parquet-format/blob/master/VariantEncoding.md")[Parquet Variant Encoding]
      · #link("https://iceberg.apache.org/spec/#semi-structured-types")[Iceberg v3 Variant]
    ]
  ]
]

#slide(title: "Shredding turns JSON paths into columns")[
  #v(1fr)
  #align(center)[
    #diagram(
      spacing: (12mm, 0mm),
      cell-size: (0pt, 54mm),
      edge-corner-radius: 4pt,
      crossing-fill: white,

      diagram-edge((0, 0), (1, 0)),
      diagram-edge((1, 0), (2, 0)),

      diagram-node(
        (0, 0),
        [
          #text(size: 13pt, weight: "semibold")[JSON VALUES]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[row 1]
          #linebreak()
          #text(size: 9.2pt)[#raw("{\"event_type\":\"signup\",")]
          #linebreak()
          #text(size: 9.2pt)[#raw(" \"user_id\":101,")]
          #linebreak()
          #text(size: 9.2pt)[#raw(" \"campaign\":\"meetup\"}")]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[row 2]
          #linebreak()
          #text(size: 9.2pt)[#raw("{\"event_type\":\"purchase\",")]
          #linebreak()
          #text(size: 9.2pt)[#raw(" \"user_id\":204,")]
          #linebreak()
          #text(size: 9.2pt)[#raw(" \"amount\":42}")]
        ],
        width: 78mm,
        height: 50mm,
      ),
      diagram-node(
        (1, 0),
        [
          #text(size: 13pt, weight: "semibold")[SHRED]
          #linebreak()
          #text(size: 9.5pt)[\$.event_type]
          #linebreak()
          #text(size: 9.5pt)[\$.user_id]
        ],
        width: 44mm,
        height: 25mm,
        accent: true,
      ),
      diagram-node(
        (2, 0),
        [
          #text(size: 13pt, weight: "semibold")[SHREDDED VARIANT COLUMN]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[metadata · field-name dictionary]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[typed_value.event_type · STRING]
          #linebreak()
          #text(size: 9.2pt)[signup | purchase]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[typed_value.user_id · INT64]
          #linebreak()
          #text(size: 9.2pt)[101 | 204]
          #linebreak()
          #text(size: 8.5pt, fill: deck-gray)[value · residual Variant]
          #linebreak()
          #text(size: 9.2pt)[#raw("{\"campaign\":\"meetup\"} | {\"amount\":42}")]
        ],
        width: 108mm,
        height: 50mm,
      ),
    )
  ]
  #v(4mm)
  #align(center)[
    #text(size: 16.5pt, weight: "semibold", fill: deck-blue)[
      Known fields become typed columns; everything else remains Variant.
    ]
  ]
  #v(1fr)
  #align(right)[
    #text(size: 7.8pt, fill: deck-gray)[
      Source: #link("https://github.com/apache/parquet-format/blob/master/VariantShredding.md")[Parquet Variant Shredding]
    ]
  ]
]

#slide(title: "Where does the Variant shape live?")[
  #v(1fr)
  #align(center)[
    // #text(size: 10pt, weight: "semibold", fill: deck-gray)[WHERE THE SHAPE LIVES]
    #v(1.5mm)
    #diagram(
      spacing: (14mm, 0mm),
      cell-size: (0pt, 34mm),

      diagram-node(
        (0, 0),
        [
          #text(size: 14pt, weight: "semibold")[VORTEX · ICEBERG · SPARK]
          #linebreak()
          #text(size: 11pt)[shape is a storage detail]
          #linebreak()
          #text(size: 11pt)[type: #text(weight: "semibold")[Variant]]
          #linebreak()
          #text(size: 11pt)[shredded paths live in the data, not the schema]
        ],
        width: 118mm,
        height: 34mm,
        accent: true,
      ),
      diagram-node(
        (1, 0),
        [
          #text(size: 14pt, weight: "semibold")[ARROW · PARQUET]
          #linebreak()
          #text(size: 11pt)[shape is part of the type]
          #linebreak()
          #text(size: 11pt)[Struct\<metadata, value?, typed_value?\>]
          #linebreak()
          #text(size: 11pt)[shred differently → different type]
        ],
        width: 118mm,
        height: 34mm,
      ),
    )
  ]
  #v(3mm)
  #align(center)[
    #text(size: 16.5pt, weight: "semibold", fill: deck-blue)[
      Keep Variant logical; shred known paths for columnar speed.
    ]
  ]
  #v(1fr)
  #align(right)[
    #text(size: 7.8pt, fill: deck-gray)[
      Sources:
      #link(
        "https://spark.apache.org/docs/latest/api/scala/org/apache/spark/sql/types/VariantType.html",
      )[Spark VariantType]
      · #link("https://github.com/vortex-data/vortex/blob/e7512cfb905c773597243c1205e0d9a4ea549300/vortex-array/src/arrays/variant/mod.rs")[Vortex VariantSlots]
      · #link("https://arrow.apache.org/docs/format/CanonicalExtensions.html")[Arrow Variant extension]
      #linebreak()
      #link("https://github.com/apache/parquet-format/blob/master/VariantShredding.md")[Parquet shredding]
      · #link("https://iceberg.apache.org/spec/#semi-structured-types")[Iceberg v3 Variant]
    ]
  ]
]

// Focus slide
#focus-slide[
  Thank You!
]

#slide(title: "Try it out!")[


  #cols()[
    #align(left, block[
      #grayed[
        ```bash
        # Rust/DataFusion
        cargo add vortex # vortex-datafusion

        # DuckDB
        INSTALL vortex;
        LOAD vortex;

        # Python
        pip install vortex-data
        ```
      ]
    ])
  ][
    #link("https://vortex.dev")

    #link("https://vortex.dev/code")

    #link("https://vortex.dev/slack")

    #link("https://bench.vortex.dev")
  ]
]


// #let bib = bibliography("bibliography.bib")
// #bibliography-slide(bib)
