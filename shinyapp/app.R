invisible(lapply(c('RgridpopUK', 'data.table', 'leaflet', 'leafgl', 'sf', 'shiny', 'shinyjs'), require, char = TRUE))
apath <- file.path(Rfuns::datauk_path, 'fb_gridpop')

ui <- fluidPage(

    useShinyjs(),
    faPlugin,
    tags$head(
        tags$title('England and Wales 30 meters Micro Grid Population'),
        tags$style("@import url('https://analytics-hub.ml/assets/icons/fontawesome/all.css;')"),
        tags$style(HTML("
            #out_map { height: calc(100vh - 80px) !important; }
            .well { 
                padding: 10px;
                height: calc(100vh - 80px);
                overflow-y: auto; 
                border: 10px;
                background-color: #EAF0F4; 
            }
            ::-webkit-scrollbar {
                width: 8px;
            }
            ::-webkit-scrollbar-track {
                background: #f1f1f1;
            }
            ::-webkit-scrollbar-thumb {
                background: #888;
            }
            ::-webkit-scrollbar-thumb:hover {
                background: #555;
            }
            .col-sm-3 { padding-right: 0; }
            #map_menu_title{ 
                margin-bottom: 10px; 
                font-weight: 700;
                font-size: 120%;
            }
        "))
    ),
    # includeCSS('./styles.css'),

    titlePanel('England and Wales Micro Grid Population'),

    fluidRow(
        column(3,
            wellPanel(
                shinyWidgets::virtualSelectInput(
                    'cbo_mso', 'MSOA:', msoa.lst, character(0), search = TRUE, 
                    placeholder = 'Select an Area', 
                    searchPlaceholderText = 'Search...', 
                    noSearchResultsText = 'No Area Found!'
                ),
                shinyWidgets::pickerInput('cbo_tpp', 'POPULATION SEGMENT:', spop.lst),
                shinyWidgets::sliderTextInput('sld_fbx', 'WEIGHT MULTIPLIER:', c(0.25, 0.5, 0.75, seq(1, 4, 0.5), 5:10), 1, grid = TRUE),
                h5(id = 'txt_num', ''),
                br(),
                selectInput('cbo_tls', 'MAPTILES:', tiles.lst, tiles.lst[[2]]),
                esquisse::palettePicker('pal_pop', 'PALETTE:', palettes.lst.pkr, selected = 'Yellow-Orange-Red',
                    textColor = c( 
                        rep('black', length(palettes.lst.pkr[[1]])), 
                        rep('white', length(palettes.lst.pkr[[2]])), 
                        rep('black', length(palettes.lst.pkr[[3]]))
                    ) 
                ),
                shinyWidgets::prettySwitch('swt_rvc', 'REVERSE PALETTE', FALSE, 'success', fill = TRUE),
                sliderInput('sld_pop', 'RADIUS POINTS:', 4, 20, 8, 1),
                shinyWidgets::colorPickr('col_mso', 'MSOA BORDER COLOUR:', 'black'),
                sliderInput('sld_mso', 'MSOA BORDER WEIGHT:', 2, 20, 6, 1)
            )
        ),
        column(9, leafglOutput('out_map', width = '100%'))
    )

)

server <- function(input, output) {

    output$out_map <- renderLeaflet({ mps })

    dts <- reactive({
            req(input$cbo_tpp)
            req(input$cbo_mso %in% msoa.lst)
            ymx <- zones[MSOA == input$cbo_mso]
            ybx <- MSOA |> subset(MSOA == input$cbo_mso) |> st_cast('MULTILINESTRING') |> merge(ymx)
            fbx <- read_fst_idx(file.path(apath, input$cbo_tpp), input$cbo_mso, cols = c('x_lon', 'y_lat', 'pop'))
            yt <- wcentroids(fbx, 27700, from_wgs = TRUE, fexp = as.numeric(input$sld_fbx))
            ymx[, `:=`( wx_lon = yt$wx_lon, wy_lat = yt$wy_lat )]
            fbx <- fbx |> st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326)
            dn <- gsub(' .*', '', names(spop.lst)[which(spop.lst == input$cbo_tpp)])
            bbx <- as.numeric(st_bbox(ybx))
            html('txt_num', paste('Found:', formatC(nrow(fbx), big.mark = ','), 'cells'))
            list('ymx' = ymx, 'ybx' = ybx, 'fbx' = fbx, 'dn' = dn, 'bbx' = bbx)
    })

    # UPDATE MAP BASED ON SEGMENT/MSOA CHOICES
    observeEvent(
        {
            input$cbo_tpp
            input$cbo_mso
        }, 
        {
            req(dts)
            mod_map() |> 
                clearShapes() |> clearGlLayers() |> clearControls() |> clearMarkers() |> 
                fitBounds(dts()$bbx[1], dts()$bbx[2], dts()$bbx[3], dts()$bbx[4]) |> 
                add_poly_msoa(dts()$ybx, dts()$ymx$MSOAn, dts()$dn, dts()$fbx$pop, input$col_mso, input$sld_mso) |> 
                add_ppop(dts()$fbx, input$sld_pop, input$pal_pop, input$swt_rvc, dts()$dn) |> 
                add_cmarkers(dts()$ymx) |> 
                end_spinmap()
        }
    )

    # UPDATE MAPTILES
    observe({ leafletProxy('out_map') |> clearTiles() |> add_maptile(input$cbo_tls) })

    # UPDATE WEIGHTED CENTROID
    observeEvent(input$sld_fbx, {
        yt <- wcentroids(dts()$fbx, 27700, from_wgs = TRUE, fexp = as.numeric(input$sld_fbx))
        leafletProxy('out_map') |> 
            clearGroup(grp_name(centroids[code == 'w'])) |> 
            add_cmarker('w', dts()$ymx, c(yt$wx_lon, yt$wy_lat))
    })

    # UPDATE POINTS STYLE 
    observeEvent(
        {
            input$pal_pop 
            input$swt_rvc 
            input$sld_pop
        },
        {
            req(dts())
            mod_map() |> 
                add_ppop(dts()$fbx, input$sld_pop, input$pal_pop, input$swt_rvc, dts()$dn) |> 
                end_spinmap()
        }
    )

    # UPDATE MSOA POLYLINE STYLE
    observeEvent(
        {
            input$col_mso
            input$sld_mso
        },
        {
            req(dts())
            mod_map() |> 
                clearGroup('msoa') |> 
                add_poly_msoa(dts()$ybx, dts()$ymx$MSOAn, dts()$dn, dts()$fbx$pop, input$col_mso, input$sld_mso) |> 
                end_spinmap()
        }
    )

}

shinyApp(ui = ui, server = server)
