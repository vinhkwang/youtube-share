import { useEffect, useRef } from 'react'
import { createConsumer } from '@rails/actioncable'

export function useActionCable(onNotification) {
  const consumerRef = useRef(null)
  const callbackRef = useRef(onNotification)

  useEffect(() => {
    callbackRef.current = onNotification
  }, [onNotification])

  useEffect(() => {
    const cableUrl = import.meta.env.VITE_CABLE_URL
    consumerRef.current = createConsumer(cableUrl)

    consumerRef.current.subscriptions.create(
      { channel: 'NotificationsChannel' },
      {
        received(data) {
          callbackRef.current?.(data)
        },
      }
    )

    return () => {
      consumerRef.current?.disconnect()
    }
  }, [])
}
