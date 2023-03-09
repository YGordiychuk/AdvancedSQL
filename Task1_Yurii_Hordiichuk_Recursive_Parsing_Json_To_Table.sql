--GIVEN STRING
WITH json_string AS
	(
		SELECT '[{"employee_id": "5181816516151", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "925155", "department_id": "1", "class": "src\bin\comp\json"}, {"employee_id": "815153", "department_id": "2", "class": "src\bin\comp\json"}, {"employee_id": "967", "department_id": "", "class": "src\bin\comp\json"}]' as [str]
	),
	
	--RECURSIVE CTE
	parse_json([employee_id], [department_id], [string]) AS(
	SELECT
		CAST(trim(' " : ' FROM right(left([str], CHARINDEX('", "', [str])), len(left([str], CHARINDEX('", "', [str]))) - CHARINDEX('": "', [str]))) AS varchar) [employee_id],
		CAST(trim(' " : ' FROM replace(right(left([str], CHARINDEX('", "class"', [str])), len(left([str], CHARINDEX('", "class"', [str]))) - CHARINDEX('"department_id": "', [str])), 'department_id": ', '')) AS varchar) [department_id],
		STUFF([str], 1, CHARINDEX('}', [str]), '') [string]
	FROM
		json_string

	UNION ALL

	SELECT
		CAST(trim(' " : ' FROM right(left([string], CHARINDEX('", "', [string])), len(left(string, CHARINDEX('", "', [string]))) - CHARINDEX('": "', [string]))) AS varchar) [employee_id],
		CAST(trim(' " : ' FROM replace(right(left([string], CHARINDEX('", "class"', [string])), len(left([string], CHARINDEX('", "class"', [string]))) - CHARINDEX('"department_id": "', [string])), 'department_id": ', '')) AS varchar) [department_id],
		STUFF([string], 1, CHARINDEX('}', [string]), '') [string]
	FROM
		parse_json
	WHERE CHARINDEX('employee_id', string) <>  0
	),

	--FINAL TRANSORMATION
	some_transformation([employee_id], [department_id]) as (
		SELECT 
			CASE WHEN LEN([employee_id]) <> 0 THEN CAST([employee_id] AS BIGINT) ELSE NULL END AS [employee_id], 
			CASE WHEN LEN([department_id]) <> 0 THEN CAST([department_id] AS BIGINT) ELSE NULL END AS [department_id]
		FROM parse_json
	)

SELECT [employee_id], [department_id] FROM some_transformation


