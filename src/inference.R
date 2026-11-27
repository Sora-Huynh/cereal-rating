# =====================================================================
# src/inference.R
# Các hàm của Mục 6.3: ANOVA một yếu tố và các kiểm định đi kèm.
# Script gọi các hàm này: analysis/04_anova.R
# Cần source("src/config.R") trước.
# Không dùng thư viện ngoài: Levene (Brown-Forsythe) và Dunn được viết lại
# theo đúng công thức ở Mục 3.4, cho kết quả trùng car::leveneTest() và
# dunn.test() / FSA::dunnTest().
# =====================================================================

# Shapiro-Wilk trên từng nhóm (Mục 3.2.3)
shapiro_by_group <- function(y, g) {
  do.call(rbind, lapply(levels(g), function(lv) {
    x <- y[g == lv]
    st <- shapiro.test(x)
    data.frame(Nhom = lv, n = length(x), W = unname(st$statistic),
               p_value = st$p.value)
  }))
}

# Levene biến thể Brown-Forsythe (Mục 3.4.3): ANOVA trên |Y_ij - trung vị nhóm i|
levene_bf <- function(y, g) {
  z <- abs(y - ave(y, g, FUN = median))
  a <- anova(lm(z ~ g))
  data.frame(F = a$`F value`[1], df1 = a$Df[1], df2 = a$Df[2], p_value = a$`Pr(>F)`[1])
}

# Bảng ANOVA đầy đủ theo Bảng 3 (Mục 3.4.4): SSB, SSW, SST, df, MS, F, p
anova_table <- function(y, g) {
  a <- anova(lm(y ~ g))
  ssb <- a$`Sum Sq`[1]; ssw <- a$`Sum Sq`[2]
  dfb <- a$Df[1];       dfw <- a$Df[2]
  data.frame(
    Nguon = c("Giữa các nhóm", "Nội bộ nhóm", "Toàn phần"),
    SS = c(ssb, ssw, ssb + ssw),
    df = c(dfb, dfw, dfb + dfw),
    MS = c(ssb / dfb, ssw / dfw, NA),
    F = c(a$`F value`[1], NA, NA),
    p_value = c(a$`Pr(>F)`[1], NA, NA),
    eta2 = c(ssb / (ssb + ssw), NA, NA)   # tỷ lệ biến thiên do yếu tố nhóm
  )
}

# Một dòng tóm tắt cho 3 kiểm định tổng thể: ANOVA cổ điển, Welch, Kruskal-Wallis
omnibus_tests <- function(y, g, label) {
  a  <- anova(lm(y ~ g))
  w  <- oneway.test(y ~ g, var.equal = FALSE)
  kw <- kruskal.test(y ~ g)
  data.frame(
    Bai_toan = label, k = nlevels(g), N = length(y),
    F = a$`F value`[1], df1 = a$Df[1], df2 = a$Df[2], p_ANOVA = a$`Pr(>F)`[1],
    F_Welch = unname(w$statistic), df2_Welch = unname(w$parameter[2]), p_Welch = w$p.value,
    H = unname(kw$statistic), df_KW = unname(kw$parameter), p_KW = kw$p.value
  )
}

# Tukey HSD (Mục 3.4.5)
tukey_table <- function(y, g) {
  tk <- TukeyHSD(aov(y ~ g), conf.level = 0.95)$g
  data.frame(Cap = rownames(tk), Chenh_lech = tk[, "diff"],
             CI_duoi = tk[, "lwr"], CI_tren = tk[, "upr"], p_adj = tk[, "p adj"],
             row.names = NULL)
}

# Dunn's test (Mục 3.4.6): z trên hạng trung bình, có hiệu chỉnh hạng trùng,
# p hai phía được hiệu chỉnh bằng method ("bonferroni" hoặc "holm")
dunn_test <- function(y, g, method = "bonferroni") {
  N <- length(y)
  r <- rank(y)
  ties <- table(r)
  tie_corr <- sum(ties^3 - ties) / (12 * (N - 1))
  rbar <- tapply(r, g, mean)
  n <- tapply(r, g, length)
  pairs <- combn(levels(g), 2)
  out <- do.call(rbind, lapply(seq_len(ncol(pairs)), function(j) {
    a <- pairs[1, j]; b <- pairs[2, j]
    se <- sqrt((N * (N + 1) / 12 - tie_corr) * (1 / n[a] + 1 / n[b]))
    z <- (rbar[a] - rbar[b]) / se
    data.frame(Cap = paste(b, "-", a), z = unname(-z), p = unname(2 * pnorm(-abs(z))))
  }))
  out$p_adj <- pmin(1, p.adjust(out$p, method = method))
  rownames(out) <- NULL
  out
}

# Thống kê mô tả của một biến theo nhóm (dùng cho bảng sugars)
group_summary <- function(y, g) {
  data.frame(Nhom = levels(g),
             n = as.vector(table(g)),
             Mean = as.vector(tapply(y, g, mean)),
             SD = as.vector(tapply(y, g, sd)),
             Median = as.vector(tapply(y, g, median)))
}

# Hình 6.3: khoảng tin cậy đồng thời Tukey HSD cho các cặp nhóm
plot_tukey <- function(tk, title) {
  tk$Cap <- factor(tk$Cap, levels = rev(tk$Cap))
  tk$Y_nghia <- ifelse(tk$p_adj < 0.05, "p < 0,05", "p ≥ 0,05")
  ggplot(tk, aes(x = Chenh_lech, y = Cap, color = Y_nghia)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_errorbar(aes(xmin = CI_duoi, xmax = CI_tren), width = 0.25, linewidth = 0.7,
                  orientation = "y") +
    geom_point(size = 2.2) +
    scale_color_manual(values = c("p < 0,05" = "#b2182b", "p ≥ 0,05" = "#4d4d4d"),
                       name = "Tukey HSD") +
    theme_minimal(base_size = 10) +
    theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 10.5),
          legend.position = "bottom") +
    labs(title = title, x = "Chênh lệch trung bình (điểm), KTC 95%", y = NULL)
}
