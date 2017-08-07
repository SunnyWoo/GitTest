class LasxController < ApiController
  def queue
    render json: {
      "123.pdf" => {
        "status" => "queued"
      },
      "234.pdf" => {
        "status" => "proccessing"
      },
      "456.pdf" => {
        "status" => "finished",
        "finished_at" => Time.now - 1.hour
      },
      "789.pdf" => {
        "status" => "error",
        "finished_at" => Time.now - 5.minutes
      }
    }
  end

  def state
    render json: {
      "status" => "Ok"
    }
  end
end
