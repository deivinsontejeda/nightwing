require "spec_helper"

describe Robin::Sidekiq::WorkerStats do
  MyWorker = Class.new

  subject { Robin::Sidekiq::WorkerStats.new(client: FakeClient.new) }

  describe "#call" do
    context "when everything just works" do
      it "increments process count" do
        expect(subject.client).to receive(:increment).with("robin.sidekiq.default.my_worker.processed")
        expect(subject.client).to receive(:increment).with("robin.sidekiq.default.my_worker.finished")

        subject.call(MyWorker.new, nil, "default") do
          # beep
        end
      end
    end

    context "when something fails" do
      it "increments process and failure count" do
        expect(subject.client).to receive(:increment).with("robin.sidekiq.default.my_worker.processed")
        expect(subject.client).to receive(:increment).with("robin.sidekiq.default.my_worker.failed")

        expect do
          subject.call(MyWorker.new, nil, "default") do
            fail "beep"
          end
        end.to raise_error RuntimeError
      end
    end
  end
end
