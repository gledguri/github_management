split_file <- function(input_file, chunk_size_mb = 20) {
	file_name <- basename(input_file)
	folder_name <- paste0(file_name, "_binary_file")

	if (!dir.exists(folder_name)) {
		dir.create(folder_name, recursive = TRUE)
	}

	chunk_size <- chunk_size_mb * 1024^2
	con <- file(input_file, "rb")
	on.exit(close(con))

	i <- 1
	repeat {
		bytes <- readBin(con, what = "raw", n = chunk_size)
		if (length(bytes) == 0) break

		chunk_name <- file.path(folder_name, sprintf("%s.part%03d", output_prefix, i))
		out <- file(chunk_name, "wb")
		writeBin(bytes, out)
		close(out)

		i <- i + 1
	}

	invisible(i - 1)
}

split_file("mfu_raw.rds", chunk_size_mb = 20)
split_file("mfu_raw.csv", chunk_size_mb = 20)

merge_rds_file <- function(folder_name) {
	if (!dir.exists(folder_name)) {
		stop("Folder does not exist: ", folder_name)
	}

	parts <- list.files(folder_name, full.names = TRUE)

	if (length(parts) == 0) {
		stop("No files found in folder: ", folder_name)
	}

	parts <- sort(parts)

	all_bytes <- raw()

	for (p in parts) {
		con <- file(p, "rb")
		bytes <- readBin(con, what = "raw", n = file.info(p)$size)
		close(con)
		all_bytes <- c(all_bytes, bytes)
	}

	raw_con <- rawConnection(all_bytes, "rb")
	on.exit(close(raw_con))

	readRDS(raw_con)
}

merge_csv_file <- function(folder_name) {
	if (!dir.exists(folder_name)) {
		stop("Folder does not exist: ", folder_name)
	}
	
	parts <- list.files(folder_name, full.names = TRUE)
	
	if (length(parts) == 0) {
		stop("No files found in folder: ", folder_name)
	}
	
	parts <- sort(parts)
	
	all_bytes <- raw()
	
	for (p in parts) {
		con <- file(p, "rb")
		bytes <- readBin(con, what = "raw", n = file.info(p)$size)
		close(con)
		all_bytes <- c(all_bytes, bytes)
	}
	
	txt <- rawToChar(all_bytes)
	text_con <- textConnection(txt)
	on.exit(close(text_con))
	
	read.csv(text_con)
}

file <- merge_rds_file("Log_D_est_smoothed.rds_binary_file")
file <- merge_csv_file("mfu_raw.csv_binary_file")
