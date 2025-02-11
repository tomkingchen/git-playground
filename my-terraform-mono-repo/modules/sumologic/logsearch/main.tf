data "sumologic_personal_folder" "personalFolder" {}

resource "sumologic_log_search" "example_log_search" {
    name = "Demo Search"
    description = "Demo search description"
    parent_id = data.sumologic_personal_folder.personalFolder.id
    query_string = <<QUERY
        _sourceCategory=api
        | parse "parameter1=*," as parameter1
        | parse "parameter2=*," as parameter2
        | where parameter1 matches {{param1}}
        | where parameter2 matches {{param2}}
        | count by _sourceHost
    QUERY
    parsing_mode =  "AutoParse"
    run_by_receipt_time = true

    time_range {
        begin_bounded_time_range {
            from {
                relative_time_range {
                    relative_time = "-30m"
                }
            }
        }
    }

    query_parameter {
        name          = "param1"
        description   = "Description for param1"
        data_type     = "STRING"
        value = "*"
    }
    query_parameter {
        name          = "param2"
        description   = "Description for param2"
        data_type     = "STRING"
        value = "*"
    }

    schedule {
        cron_expression = "0 0 * * * ? *"
        mute_error_emails = false
        notification {
            email_search_notification {
                include_csv_attachment = false
                include_histogram = false
                include_query = true
                include_result_set = true
                subject_template = "Search Alert: {{TriggerCondition}} found for {{SearchName}}"
                to_list = [
                    "will@acme.com",
                ]
            }
        }
        parseable_time_range {
            begin_bounded_time_range {
                from {
                    relative_time_range {
                        relative_time = "-15m"
                    }
                }
            }
        }
        schedule_type = "1Week"
        threshold {
            count = 10
            operator = "gt"
            threshold_type = "group"
        }
        time_zone = "America/Los_Angeles"

        parameter {
            name = "param1"
            value = "*"
        }
        parameter {
            name = "param2"
            value = "*"
        }
    }
}
