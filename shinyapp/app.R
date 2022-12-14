# estrare valori UFFICIALI comuni dei corrispondenti segmenti popolazione
# Titolo Mappa?
# Stampa Mappa. tmap? ggplot2?

Rfuns::load_pkgs(uk = TRUE, 'Rgridpop', 'Rshiny', 'data.table', 'leaflet', 'leafgl', 'shiny', 'shinyjs')
apath <- file.path(datauk_path, 'gridpop', 'facebook')

credits <- '
    <ul>
        <li>
            Facebook Connectivity Lab and Center for International Earth Science Information Network - CIESIN - Columbia University. 2016. \n
            High Resolution Settlement Layer (HRSL). Source imagery for HRSL © 2016 DigitalGlobe. \n
            <a href="https://data.humdata.org/dataset/united-kingdom-high-resolution-population-density-maps-demographic-estimates">Data accessed 01 Jun 2022</a>.
        </li>
        <li>
            Contains Parliamentary information licensed under the 
            <a href="https://www.parliament.uk/site-information/copyright/open-parliament-licence/">Open Parliament Licence v3.0</a>.
        </li>
        <li>
            Boundaries Sources: 
              <a href="https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(BDY_MSOA%2CDEC_2011)">Office for National Statistics</a> 
              and
              <a href="https://spatialdata.gov.scot/geonetwork/srv/eng/catalog.search#/metadata/389787c0-697d-4824-9ca9-9ce8cb79d6f5">Scottish Government</a>
              licensed under the <a href="https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/">Open Government Licence v.3.0</a>.
        </li>
        <li>
            Contains Ordnance Survey data © Crown copyright and database right [2022].
        </li>
    </ul>
'

ui <- fluidPage(

    useShinyjs(),
    faPlugin,
    tags$head(
        tags$title('Popolazione a microgriglie'),
        tags$style("@import url('https://datamaps.uk/assets/icons/font-awesome/all.css;')"),
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
    
    titlePanel('Popolazione a microgriglie'),

    fluidRow(
        column(3,
            wellPanel(
                shinyWidgets::virtualSelectInput(
                    'cbo_msoa', 'MSOA:', msoa.lst, character(0), search = TRUE, 
                    placeholder = 'Select an Area', 
                    searchPlaceholderText = 'Search...', 
                    noSearchResultsText = 'No Area Found!'
                ),
                shinyWidgets::pickerInput('cbo_tpp', 'POPULATION SEGMENT:', fb_pop.lst),
                sliderInput('sld_fbx', 'WEIGHT MULTIPLIER:', 0.5, 8, 3, 0.5),
                h5(id = 'txt_num', ''),
                br(),
                selectInput('cbo_tls', 'MAPTILES:', tiles.lst, tiles.lst[[2]]),
                masterPalette('col_pop', 'COLOURS PALETTE:', 'Reds'),
                shinyWidgets::prettySwitch('swt_rvc', 'REVERSE PALETTE', FALSE, 'success', fill = TRUE),
                sliderInput('sld_pop', 'RADIUS POINTS:', 4, 20, 8, 1),
                masterColore('col_com', 'MSOA BORDER COLOUR:', 'black'), 
                sliderInput('sld_com', 'MSOA BORDER WEIGHT:', 2, 20, 6, 1),
            )
        ),
        column(9, leafglOutput('out_map', width = '100%'))
    )
    
)

server <- function(input, output) {

    # INIZIALIZZAZIONE MAPPA
    output$out_map <- renderLeaflet({ mps })

    # DETERMINO DATASETS
    dts <- reactive({
        
            req(input$cbo_tpp)
            req(input$cbo_cmn %in% yc$CMN)
            
            ycx <- yc[CMN == input$cbo_cmn]
            ybx <- yb |> subset(CMN == input$cbo_cmn) |> sf::st_cast('MULTILINESTRING') |> merge(ycx)
            # fbx <- read_fst_idx(file.path(apath, input$cbo_tpp), input$cbo_cmn, cols = c('x_lon', 'y_lat', 'pop')) |> 
            #             sf::st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326)
            fbx <- read_fst_idx(file.path(apath, input$cbo_tpp), input$cbo_cmn, cols = c('x_lon', 'y_lat', 'pop'))
            fbx[, `:=`( x_lon = x_lon + 0.00025 )]
            print(fbx)
            print(input$sld_fbx)
            yt <- calcola_pesato(fbx, fexp = as.numeric(input$sld_fbx))
            print(yt)
            print(ycx)
            ycx[, `:=`( wx_lon = yt$wx_lon, wy_lat = yt$wy_lat )]
            fbx <- fbx |> sf::st_as_sf(coords = c('x_lon', 'y_lat'), crs = 4326)
            dn <- gsub(' .*', '', names(fb_pop.lst)[which(fb_pop.lst == input$cbo_tpp)])
            bbx <- as.numeric(sf::st_bbox(ybx))
            
            shinyjs::html('txt_num', paste('Estratte', formatCit(nrow(fbx)), 'griglie'))
            list('ycx' = ycx, 'ybx' = ybx, 'fbx' = fbx, 'dn' = dn, 'bbx' = bbx)
            
    })
    
    # AGGIORNAMENTO MAPPA SCELTA TIPO POPOLAZIONE o COMUNE
    observeEvent(
        {
            input$cbo_tpp 
            input$cbo_cmn
        }, 
        {
            
            req(dts)
            pal <- colorNumeric(liste[grepl('palette', lista) & nome == input$col_pop, elemento], dts()$fbx$pop, reverse = input$swt_rvc)
            
            y <- leafletProxy('out_map') |>
                    removeShape(layerId = 'spinnerMarker') |>
                    clearShapes() |> clearGlLayers() |> clearControls() |> clearMarkers() |> 
                    fitBounds(dts()$bbx[1], dts()$bbx[2], dts()$bbx[3], dts()$bbx[4]) |> 
                    addPolylines(
                        data = dts()$ybx,
                        group = 'comune',
                        color = input$col_com, 
                        weight = input$sld_com,
                        opacity = 1,
                        fillOpacity = 0, 
                        label = paste0('Popolazione ', dts()$dn, ' ', dts()$ycx$CMNd, ': ', formatCit(round(sum(dts()$fbx$pop)))),
                        highlightOptions = hlt.options
                    ) |>
                    addGlPoints(
                        data = dts()$fbx, 
                        group = 'gridpop',
                        radius = input$sld_pop,
                        fragmentShaderSource = 'square',
                        fillColor = ~pal(pop), fillOpacity = 1, 
                        popup = ~formatCit(pop, 2)
                    )
            grps <- NULL
            for(idx in 1:nrow(tipi_centroidi)){
                tx <- tipi_centroidi[idx]
                grp <- paste0(
                        '<span style="color: ', tx$fColore,'">
                            &nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp',
                        '</span>', tx$descrizione
                )
                grps <- c(grps, grp)
                y <- y |> 
                        addAwesomeMarkers(
                            data = dts()$ycx, lng = ~get(paste0(tx$sigla, 'x_lon')), lat = ~get(paste0(tx$sigla, 'y_lat')),
                            group = grp,
                            icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColore, iconColor = tx$colore),
                            label = tx$descrizione
                        )
            }
        
            y |> 
                addLegend(
                    position = 'bottomright',
                    layerId = 'legenda',
                    pal = pal, values = dts()$fbx$pop, 
                    opacity = 1, 
                    title = dts()$dn
                )  |> 
                addLayersControl( overlayGroups = grps, options = layersControlOptions(collapsed = FALSE) ) |>  
                # TITOLO? 
                # addControl() |> 
                fine_mappa_spin()

        }
    )
    
    # AGGIORNAMENTO TESSERE MAPPA
    observe({ leafletProxy('out_map') |> clearTiles() |> aggiungi_tessera(input$cbo_tls) })
    
    # observeEvent(input$sld_fbx, {
    #     tx <- tipi_centroidi[sigla == 'w']
    #     grp <- paste0('<span style="color: ', tx$fColore,'">&nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp','</span>', tx$descrizione)
    #     leafletProxy('out_map') |>
    #         clearGroup(grp) |> 
    #         y <- y |>
    #                 addAwesomeMarkers(
    #                     data = dts()$ycx, lng = ~get(paste0(tx$sigla, 'x_lon')), lat = ~get(paste0(tx$sigla, 'y_lat')),
    #                     group = grp,
    #                     icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColore, iconColor = tx$colore),
    #                     label = tx$descrizione
    #                 )
    # })
    
    # AGGIORNAMENTO MAPPA STILI PUNTI/VORONOI
    observeEvent(
        {
            input$col_pop 
            input$swt_rvc 
            input$sld_pop
        },
        {
            
            req(dts())
            
            pal <- colorNumeric(liste[grepl('palette', lista) & nome == input$col_pop, elemento], dts()$fbx$pop, reverse = input$swt_rvc)
            y <- leafletProxy('out_map') |>
                    removeShape(layerId = 'spinnerMarker') |>
                    clearGroup('gridpop') |> removeControl('legenda') |> clearMarkers() |> 
                    addGlPoints(
                        data = dts()$fbx, 
                        group = 'gridpop',
                        radius = input$sld_pop,
                        fragmentShaderSource = 'square',
                        fillColor = ~pal(pop), fillOpacity = 1, 
                        popup = ~formatCit(pop, 2)
                    )
            grps <- NULL
            for(idx in 1:nrow(tipi_centroidi)){
                tx <- tipi_centroidi[idx]
                grp <- paste0(
                        '<span style="color: ', tx$fColore,'">
                            &nbsp<i class="fa fa-', tx$icon, '"></i>&nbsp',
                        '</span>', tx$descrizione
                )
                grps <- c(grps, grp)
                y <- y |>
                        addAwesomeMarkers(
                            data = dts()$ycx, lng = ~get(paste0(tx$sigla, 'x_lon')), lat = ~get(paste0(tx$sigla, 'y_lat')),
                            group = grp,
                            icon = makeAwesomeIcon(icon = tx$icona, library = "fa", markerColor = tx$fColore, iconColor = tx$colore),
                            label = tx$descrizione
                        )
            }
            
            y |>
                addLegend(
                    position = 'bottomright',
                    layerId = 'legenda',
                    pal = pal, values = dts()$fbx$pop,
                    opacity = 1,
                    title = dts()$dn
                ) |> 
                fine_mappa_spin()
            
        }
        
    )

    # AGGIORNAMENTO MAPPA STILI POLIGONO COMUNE
    observeEvent(
        {
            input$col_com
            input$sld_com
        },
        {
            
            req(dts())
            
            leafletProxy('out_map') |>
                removeShape(layerId = 'spinnerMarker') |>
                clearGroup('comune') |> 
                addPolylines(
                    data = dts()$ybx,
                    group = 'comune',
                    color = input$col_com, 
                    weight = input$sld_com,
                    opacity = 1,
                    fillOpacity = 0, 
                    label = paste0('Population ', dts()$dn, ' ', dts()$ycx$CMNd, ': ', formatCit(round(sum(dts()$fbx$pop)))),
                    highlightOptions = hlt.options
                ) |> 
                fine_mappa_spin()
            
        }
        
    )

}

shinyApp(ui = ui, server = server)
