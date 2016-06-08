navigator.getUserMedia = navigator.getUserMedia ? navigator.webkitGetUserMedia

FFT_SIZE = 2048
TAIL_BINS = 100

$ ->

  undertone = window.undertone()
  context = new AudioContext()

  canvas = $('canvas.listen')[0]
  canvas_context = canvas.getContext('2d')

  navigator.getUserMedia audio: true, (stream) ->

    # Trying to read the raw stream

    media_recorder = new MediaRecorder(stream)
    media_recorder.start(1000)
    media_recorder.ondataavailable = (event) ->
      console.log event.data[0], event.data

    # Using the built-in audio analyser stuff

    analyser = context.createAnalyser()
    analyser.fftSize = FFT_SIZE

    source = context.createMediaStreamSource(stream)
    source.connect(analyser)

    audio_buffer = new Float32Array(analyser.fftSize)
    frequency_buffer = new Float32Array(analyser.frequencyBinCount)

    setInterval ->

      analyser.getFloatTimeDomainData(audio_buffer)
      analyser.getFloatFrequencyData(frequency_buffer)

      canvas_context.clearRect(0, 0, canvas.width, canvas.height)
      canvas_context.beginPath()
      canvas_context.moveTo(0, canvas.height)
      tail = frequency_buffer[1024-TAIL_BINS...]
      for y, x in tail
        canvas_context.lineTo(x/tail.length  * canvas.width, -y/256 * canvas.height)
      canvas_context.stroke()
    , 0

    $('#listen').click ->
      console.log('listening')
      undertone.listen(stream).then (data) ->
        console.log data

  , (error) ->
    console.log error

  $('#broadcast').click ->
    console.log('broadcasting')
    undertone.broadcast("ABC123")


