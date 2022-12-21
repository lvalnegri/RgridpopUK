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
                sliderInput('sld_fbx', 'WEIGHT MULTIPLIER:', 0.5, 8, 3, 0.5),
                h5(id = 'txt_num', ''),
                br(),
                selectInput('cbo_tls', 'MAPTILES:', tiles.lst, tiles.lst[[2]]),
                esquisse::palettePicker('pal_pop', 'PALETTE:', palettes.lst.pkr, selected = 'Red-Yellow-Blue',
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
            # y <- lapply(names(palettes.lst), \(x) which(names(palettes.lst[[x]]) == input$pal_pop))
            # pal <- colorNumeric(as.character(palettes.lst[[which(y > 0)]][unlist(y)]), dts()$fbx$pop, reverse = input$swt_rvc)
          print(dts()$ymx)
          
            leafletProxy('out_map') |>
                    removeShape(layerId = 'spinnerMarker') |>
                    clearShapes() |> clearGlLayers() |> clearControls() |> clearMarkers() |> 
                    fitBounds(dts()$bbx[1], dts()$bbx[2], dts()$bbx[3], dts()$bbx[4]) |> 
                    # addPolylines(
                    #     data = dts()$ybx,
                    #     group = 'msoa',
                    #     color = input$col_mso, 
                    #     weight = input$sld_mso,
                    #     opacity = 1,
                    #     fillOpacity = 0, 
                    #     label = HTML(paste0('<b>MSOA</b>: ', dts()$ymx$MSOAn, '<br><b>', dts()$dn, '</b>: ', formatC(round(sum(dts()$fbx$pop)), big.mark = ','))),
                    #     highlightOptions = highlightOptions(color = 'white', weight = 6, opacity = 1, bringToFront = TRUE, sendToBack = TRUE)
                    # ) |>
                    add_poly_msoa(dts()$ybx, dts()$ymx$MSOAn, dts()$dn, dts()$fbx$pop, input$col_mso, input$sld_mso) |> 
                    # addGlPoints(
                    #     data = dts()$fbx, 
                    #     group = 'gridpop',
                    #     radius = input$sld_pop,
                    #     fragmentShaderSource = 'square',
                    #     fillColor = ~pal(pop), 
                    #     fillOpacity = 1, 
                    #     popup = ~paste('Density: ', formatC(pop, 2))
                    # )
                    add_ppop(dts()$fbx, input$sld_pop, input$pal_pop, input$swt_rvc,dts()$dn) |> 
                    # addLegend(
                    #   position = 'bottomright',
                    #   group = 'gridpop',
                    #   layerId = 'legend',
                    #   pal = pal, values = dts()$fbx$pop,
                    #   opacity = 1,
                    #   title = dts()$dn
                    # ) 
                    add_cmarkers(dts()$ymx) |> 
            # grps <- NULL
            # for(idx in 1:nrow(centroids)){
            #     tx <- centroids[idx]
            #     grp <- paste0( '<span style="color:', tx$fColour,'">&nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp', '</span>', tx$description )
            #     grps <- c(grps, grp)
            #     y <- y |> 
            #             addAwesomeMarkers(
            #                 data = dts()$ymx, 
            #                 lng = ~get(paste0(tx$code, 'x_lon')), 
            #                 lat = ~get(paste0(tx$code, 'y_lat')),
            #                 group = grp,
            #                 icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColour, iconColor = tx$colour),
            #                 label = tx$description
            #             )
            # }
            # 
            # y |>
            #     addLayersControl( overlayGroups = grps, options = layersControlOptions(collapsed = FALSE) ) |>
                # # TITLE?
                # # addControl() |>
                end_spinmap()

        }
    )

    # UPDATE MAPTILES
    observe({ leafletProxy('out_map') |> clearTiles() |> add_maptile(input$cbo_tls) })

    # UPDATE WEIGHTED CENTROID
    observeEvent(input$sld_fbx, {
        yt <- wcentroids(dts()$fbx, 27700, from_wgs = TRUE, fexp = as.numeric(input$sld_fbx))
        tx <- centroids[code == 'w']
        grp <- paste0( '<span style="color:', tx$fColour,'">&nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp', '</span>', tx$description )
        leafletProxy('out_map') |>
            clearGroup(grp) |>
            addAwesomeMarkers(
                data = dts()$ymx, 
                lng = yt$wx_lon, 
                lat = yt$wy_lat,
                group = grp,
                icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColour, iconColor = tx$colour),
                label = tx$description
            )
    })

    # UPDATE POINTS SHAPE 
    observeEvent(
        {
            input$pal_pop 
            input$swt_rvc 
            input$sld_pop
        },
        {

            req(dts())

            pal <- colorNumeric(input$pal_pop, dts()$fbx$pop, reverse = input$swt_rvc)
            y <- leafletProxy('out_map') |>
                    removeShape(layerId = 'spinnerMarker') |>
                    clearGroup('gridpop') |> removeControl('legend') |> clearMarkers() |> 
                    add_ppop(dts()$fbx, input$sld_pop)
                    # addGlPoints(
                    #     data = dts()$fbx, 
                    #     group = 'gridpop',
                    #     radius = input$sld_pop,
                    #     fragmentShaderSource = 'square',
                    #     fillColor = ~pal(pop), 
                    #     fillOpacity = 1, 
                    #     popup = ~formatC(pop, 2)
                    # )
            grps <- NULL
            for(idx in 1:nrow(centroids)){
                tx <- centroids[idx]
                grp <- paste0( '<span style="color: ', tx$fColour,'">&nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp', '</span>', tx$description )
                grps <- c(grps, grp)
                y <- y |>
                        addAwesomeMarkers(
                            data = dts()$ymx, lng = ~get(paste0(tx$code, 'x_lon')), lat = ~get(paste0(tx$code, 'y_lat')),
                            group = grp,
                            icon = makeAwesomeIcon(icon = tx$icon, library = 'fa', markerColor = tx$fColour, iconColor = tx$colour),
                            label = tx$description
                        )
            }

            y |>
                addLegend(
                    position = 'bottomright',
                    layerId = 'legend',
                    pal = pal, values = dts()$fbx$pop,
                    opacity = 1,
                    title = dts()$dn
                ) |> 
                end_spinmap()
            
        }

    )

    # UPDATE MSOA POLYGONS STYLE
    observeEvent(
        {
            input$col_mso
            input$sld_mso
        },
        {
            req(dts())
            leafletProxy('out_map') |>
                removeShape(layerId = 'spinnerMarker') |>
                clearGroup('msoa') |> 
                add_poly_msoa(dts()$ybx, dts()$ymx$MSOAn, dts()$dn, dts()$fbx$pop, input$col_mso, input$sld_mso) |> 
                end_spinmap()
        }
    )

}

shinyApp(ui = ui, server = server)
