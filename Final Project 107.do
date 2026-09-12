import delimited "C:\Users\maxa\Documents\EC107\Raw Data\nfl_betting_ready_stata.csv"
keep if schedule_season == 2024
replace schedule_week = "19" if schedule_week == "Wildcard"
replace schedule_week = "20" if schedule_week == "Division"
replace schedule_week = "21" if schedule_week == "Conference"
replace schedule_week = "22" if schedule_week == "Superbowl"
destring schedule_week, replace

gen playoff_num = .
replace playoff_num = 1 if schedule_playoff == "TRUE"
replace playoff_num = 0 if schedule_playoff == "FALSE"

gen score_diff = score_home - score_away
gen betting_error = abs(score_diff + spread_home)
reg betting_error combined_dma_households schedule_week playoff_num, robust

twoway histogram betting_error, name(g1)
twoway histogram combined_dma_households, name(g2)
graph combine g1 g2, name(g3)

summarize betting_error combined_dma_households schedule_week playoff_num
corr betting_error combined_dma_households

twoway (scatter betting_error combined_dma_households) (lfit betting_error combined_dma_households), ///
	ytitle("Betting Error") ///
    xtitle("Combined DMA Households") ///
	name(g4)
	
reg betting_error schedule_week playoff_num
predict uhat_y, residuals
reg combined_dma_households schedule_week playoff_num
predict uhat_x, residuals
twoway (scatter uhat_y uhat_x) (lfit uhat_y uhat_x), name(g5)

destring over_under_line, replace
reg betting_error combined_dma_households schedule_week playoff_num over_under_line, robust

gen betting_error_weighted = betting_error / (score_home + score_away)
reg betting_error_weighted combined_dma_households schedule_week playoff_num, robust

reg betting_error c.combined_dma_households##i.playoff_num schedule_week, robust
test combined_dma_households c.combined_dma_households#1.playoff_num

gen outdoor_game = 1
	replace outdoor_game = 0 if weather_detail == "indoor"
reg betting_error combined_dma_households schedule_week playoff_num if outdoor_game == 1, robust
reg betting_error outdoor_game, robust