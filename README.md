UPDATE: organized the repo into folders and updated readme to be more organized and comprehensive

**Project Summary:**  
This project analyzes historical MLB data using advanced SQL techniques to uncover long term trends in player careers, team spending behavior, and franchise level performance patterns across decades

---

**Analysis Highlights:**  
- Examined decade over decade changes in player physical attributes and batting distributions  
- Identified the first season each franchise surpassed $1 billion in cumulative payroll  
- Measured career longevity and team retention patterns  
- Ranked top performing schools and franchises using window functions  

---

**Techniques & Concepts:**  
- Complex joins across relational tables  
- CTEs for multi step transformations  
- Window functions (ROW_NUMBER, NTILE, LAG)  
- Aggregations and percentile segmentation  
- Trend and milestone analysis  

---

**Key Results:**

"Examined decade over decade changes in player physical attributes"  




|decade|avg_height|avg_weight|diff_in_HEIGHT|diff_in_WEIGHT|
|------|----------|----------|--------------|--------------|
|1870  |68.8415   |163.1394  |NULL          |NULL          |
|1880  |69.5838   |169.0087  |0.7423        |5.8693        |
|1890  |69.9861   |170.3323  |0.4023        |1.3236        |
|1900  |70.5297   |174.0783  |0.5436        |3.7460        |
|1910  |70.7816   |171.8658  |0.2519        |-2.2125       |
|1920  |70.9092   |173.0967  |0.1276        |1.2309        |
|1930  |71.6435   |178.8141  |0.7343        |5.7174        |
|1940  |72.0514   |182.3502  |0.4079        |3.5361        |
|1950  |72.4654   |184.4131  |0.4140        |2.0629        |
|1960  |72.8793   |185.8705  |0.4139        |1.4574        |
|1970  |73.0714   |186.0540  |0.1921        |0.1835        |
|1980  |73.3436   |187.7023  |0.2722        |1.6483        |
|1990  |73.4896   |193.8888  |0.1460        |6.1865        |
|2000  |73.6789   |205.8854  |0.1893        |11.9966       |
|2010  |73.6043   |207.3201  |-0.0746       |1.4347        |

---

"Identified the first season each franchise surpassed $1 billion in cumulative payroll"  



|teamID|yearID|cumulative_sum_billions|
|------|------|-----------------------|
|ARI   |2012  |1.02                   |
|ATL   |2005  |1.07                   |
|BAL   |2007  |1.06                   |
|BOS   |2004  |1.00                   |
|CHA   |2008  |1.07                   |
|CHN   |2007  |1.08                   |
|CIN   |2010  |1.06                   |
|CLE   |2009  |1.06                   |
|COL   |2011  |1.05                   |
|DET   |2009  |1.11                   |
|HOU   |2008  |1.03                   |
|KCA   |2012  |1.02                   |
|LAA   |2013  |1.06                   |
|LAN   |2005  |1.08                   |
|MIL   |2014  |1.05                   |
|MIN   |2011  |1.02                   |
|NYA   |2003  |1.06                   |
|NYN   |2005  |1.04                   |
|OAK   |2012  |1.05                   |
|PHI   |2008  |1.03                   |
|SDN   |2012  |1.04                   |
|SEA   |2007  |1.04                   |
|SFN   |2007  |1.04                   |
|SLN   |2007  |1.07                   |
|TEX   |2007  |1.04                   |
|TOR   |2008  |1.05                   |



## Repository Structure

```text
SQL-Data-Analysis-Project-Historical-Baseball-Dataset/
│
├── Dataset Files/             # Datasets used in the project
├── Project Code/              # The project's SQL Code
└── README.md                  # Project documentation
```
