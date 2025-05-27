require "test_helper"

class InstitutionSyncJobTest < ActiveJob::TestCase
  test "job is queued on default queue" do
    assert_equal "default", InstitutionSyncJob.queue_name
  end

  test "sync_now enqueues job" do
    # Since we're using Sidekiq, test that the method exists and returns a job
    job = InstitutionSyncJob.sync_now
    assert_not_nil job
    assert_kind_of InstitutionSyncJob, job
  end

  test "job_stats returns hash with expected keys" do
    stats = InstitutionSyncJob.job_stats

    assert_kind_of Hash, stats
    assert_includes stats.keys, :enqueued
    assert_includes stats.keys, :processing
    assert_includes stats.keys, :failed
  end

  test "perform calls InstitutionSyncService" do
    # Mock the service to avoid actual API calls
    mock_result = {
      created: 5,
      updated: 3,
      errors: [],
      total_processed: 8
    }

    InstitutionSyncService.expects(:sync_all_institutions).returns(mock_result)

    job = InstitutionSyncJob.new
    result = job.perform([ "US" ])

    assert_equal mock_result, result
  end
end
